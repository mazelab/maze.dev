class configure::php
{
    include phpfpm

    package { ['php5', 'postfix', 'mc', 'g++', 'libexpat1-dev']:
        ensure => latest,
    }
    package { ["php5-mcrypt"]:
        require => [Class["nginx::install"], Package["php5-fpm"]],
        ensure  => latest,
        notify  => Class['phpfpm::service']
    }

    file_line { '/etc/php5/fpm/pool.d/www.conf - www-user':
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => 'user = vagrant',
        require => [Class['nginx::install'], Package['php5-fpm']],
    }
    file_line { '/etc/php5/fpm/pool.d/www.conf - www-group':
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => 'group = vagrant',
        require => [Class['nginx::install'], Package['php5-fpm']],
    }

    file_line { 'xdebug enable':
        path => '/etc/php5/conf.d/xdebug.ini',
        line => 'xdebug.remote_enable=1',
        require => [Class['nginx::install'], Package['php5-fpm', 'php5-xdebug']],
    }
    file_line { 'xdebug handler':
        path => '/etc/php5/conf.d/xdebug.ini',
        line => 'xdebug.remote_handler=dbgp',
        require => [Class['nginx::install'], Package['php5-fpm', 'php5-xdebug'], File_line['xdebug enable']],
    }
    file_line { 'xdebug host':
        path => '/etc/php5/conf.d/xdebug.ini',
        line => 'xdebug.remote_host=10.0.2.2',
        require => [Class['nginx::install'], Package['php5-fpm', 'php5-xdebug'], File_line['xdebug handler']],
    }
    file_line { 'xdebug port':
        path => '/etc/php5/conf.d/xdebug.ini',
        line => 'xdebug.remote_port=9000',
        require => [Class['nginx::install'], Package['php5-fpm', 'php5-xdebug'], File_line['xdebug host']],
        notify => Class['phpfpm::service']
    }

}