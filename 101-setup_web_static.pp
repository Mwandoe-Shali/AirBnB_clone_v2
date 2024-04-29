# setup web server for deployment

file { '/etc/nginx/sites-available/default':
  ensure => present,
  content => "
    server {
        listen 80 default_server;
        listen [::]:80 default_server;        

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;
        add_header X-Served-By ${hostname};

        location /hbnb_static {
            alias /data/web_static/current/;
        }

        location /redirect_me {
            return 301 http://github.com/Mwandoe-Shali/;
        }

        error_page 404 /404.html
        location /404 {
            root /var/www/html:
            internal;
        }
    }
  ",
  notify => Service['nginx'],
}

service { 'nginx':
  ensure => running,
  enable => true,
  require => File['/etc/nginx/sites-available/default'],
}

package { 'nginx':
  ensure   => 'present',
  provider => 'apt'
} ->

$directories = ['/data', '/data/web_static', '/data/web_static/releases',
                '/data/web_static/releases/test', '/data/web_static/shared']

file { $directories:
  ensure => 'directory',
}

file { '/data/web_static/releases/test/index.html':
  ensure  => 'present',
  content => "Holberton School Puppet\n"
} ->

file { '/data/web_static/current':
  ensure => 'link',
  target => '/data/web_static/releases/test'
} ->

exec { 'chown -R ubuntu:ubuntu /data/':
  path => '/usr/bin/:/usr/local/bin/:/bin/'
}

file { '/var/www':
  ensure => 'directory'
} ->

file { '/var/www/html':
  ensure => 'directory'
} ->

file { '/var/www/html/index.html':
  ensure  => 'present',
  content => "Holberton School Nginx\n"
} ->

file { '/var/www/html/404.html':
  ensure  => 'present',
  content => "Ceci n'est pas une page\n"
} ->

exec { 'nginx restart':
  path => '/etc/init.d/'
}