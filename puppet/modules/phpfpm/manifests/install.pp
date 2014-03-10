class phpfpm::install {
	
	@package { ['php5-curl', 'php5-fpm', 'php5-cli', 'php5-xdebug', 'php5-gd', 'php-pear', 'make', 'libssh2-1-dev']:
		ensure => installed,
	}
    realize (
      Package['php5-curl', 'php5-fpm', 'php5-cli', 'php5-xdebug', 'php-pear', 'make', 'libssh2-1-dev']
    ) 
    exec {
        "php5-mongodb-extention" :
            command => "/usr/bin/pecl install mongo",
            cwd => "/usr/bin",
            logoutput => on_failure,
            unless => "pecl list|grep mongo",
            require => [Package['php-pear'], Package['php5-cli'], Package['make']],
            notify => Class['phpfpm::service'],
    }

    exec {
        "php5-ssh2-extention" :
            command => "/usr/bin/pecl install channel://pecl.php.net/ssh2-0.11.3",
            cwd => "/usr/bin",
            logoutput => on_failure,
            unless => "pecl info ssh2",
            require => [Package['php-pear'], 
                Package['php5-cli'], Exec['php5-mongodb-extention'],
                Package['make'], Package['libssh2-1-dev']],
            notify => Class['phpfpm::service'],
    }

    file { "/etc/php5/conf.d/mongo.ini":
        owner => root,
        group => root,
        mode => 664,
        content => "extension=mongo.so",
        require => [Package['php5-fpm'], Package['php5-cli']],
        notify => Class['phpfpm::service'],
    }

    file { "/etc/php5/conf.d/ssh2.ini":
        owner => root,
        group => root,
        mode => 664,
        content => "extension=ssh2.so",
        require => [Package['php5-fpm'], Package['php5-cli']],
        notify => Class['phpfpm::service'],
    }

    file { "/etc/php5/conf.d/fastcgi.ini":
        owner => root,
        group => root,
        mode => 664,
        content => 'fastcgi.error_header = "HTTP/1.1 500 Internal Server Error"',
        require => [Package['php5-fpm'], Package['php5-cli']],
        notify => Class['phpfpm::service'],
    }

    file { "/etc/php5/conf.d/gd.ini":
        owner => root,
        group => root,
        mode => 664,
        content => "extension=gd.so",
        require => [Package['php5-gd']],
        notify => Class['phpfpm::service', 'nginx::service'],
    }
}