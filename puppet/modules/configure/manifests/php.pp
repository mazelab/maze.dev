class configure::php (
    $user                 = 'vagrant',
    $group                = 'vagrant'
) {

    service { 'php5-fpm':
      ensure     => true,
      hasstatus  => true,
      hasrestart => true
    }

    package{ ['php-pear', 'php5-cli', 'make']:
        ensure => 'latest'
    }

    php::module{ ['gd', 'fpm', 'mcrypt', 'xdebug', 'cli', 'curl']:}

    file_line { "php5-fpm user - $user":
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => "user = $user",
        require => Package['php5-fpm'],
        notify => Service['php5-fpm']
    }
    file_line { "php5-fpm group - $group":
        path => '/etc/php5/fpm/pool.d/www.conf',
        line => "group = $group",
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