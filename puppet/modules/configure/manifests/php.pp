class configure::php (
) {

    service { 'php5-fpm':
      ensure     => true,
      hasstatus  => true,
      hasrestart => true
    }

    package{ ['php-pear', 'make']:
        ensure => 'latest'
    }

    php::module{ ['gd', 'fpm', 'mcrypt', 'xdebug', 'cli', 'curl']:}

    file_line { '/etc/php5/fpm/pool.d/www.conf - www-user':
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => 'user = vagrant',
        require => Package['php5-fpm'],
        notify => Service['php5-fpm']
    }
    file_line { '/etc/php5/fpm/pool.d/www.conf - www-group':
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => 'group = vagrant',
        require => Package['php5-fpm'],
        notify => Service['php5-fpm']
    }

    php::conf{'xdebug.conf':
        path => '/etc/php5/conf.d/xdebug.conf.ini',
        template => 'configure/xdebug.conf',
        notify => Service['php5-fpm']
    }

    php::conf{'mongo.ini':
        path => '/etc/php5/conf.d/mongo.ini',
        content => 'extension=mongo.so',
        require => Exec['php5-mongodb-extention'],
        notify => Service['php5-fpm']
    }

    exec {"php5-mongodb-extention" :
        command => "/usr/bin/pecl install mongo",
        cwd => "/usr/bin",
        logoutput => on_failure,
        unless => "pecl list|grep mongo",
        require => [Package['php-pear'], Package['php5-cli'], Package['make']],
        notify => Service['php5-fpm']
    }

}