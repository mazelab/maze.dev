class composer(
  $target_dir      = '/usr/local/bin',
  $composer_file   = 'composer',
  $logoutput       = false,
  $tmp_path        = '/tmp') {

  include augeas

  $php_package     = 'php5-cli'

  # download composer
  exec { 'download_composer':
    command     => 'wget http://getcomposer.org/composer.phar -O composer.phar',
    cwd         => $tmp_path,
    creates     => "$tmp_path/composer.phar",
    logoutput   => $logoutput,
  }

  # check if directory exists
  file { $target_dir:
    ensure      => directory,
  }

  # move file to target_dir
  file { "$target_dir/$composer_file":
    ensure      => present,
    source      => "$tmp_path/composer.phar",
    require     => [ Exec['download_composer'], File[$target_dir], ],
    group       => 'staff',
    mode        => '0755',
  }

  # run composer self-update
  exec { 'update_composer':
    command     => "$target_dir/$composer_file self-update",
    require     => File["$target_dir/$composer_file"],
  }

  # set /etc/php5/cli/php.ini/suhosin.executor.include.whitelist = phar
#  augeas { 'whitelist_phar':
#    context     => '/files/etc/php5/conf.d/suhosin.ini/suhosin',
#    changes     => 'set suhosin.executor.include.whitelist phar',
#    require     => Package[$php_package],
#  }

  # set /etc/php5/cli/php.ini/PHP/allow_url_fopen = On
#  augeas{ 'allow_url_fopen':
#    context     => '/files/etc/php5/cli/php.ini/PHP',
#    changes     => 'set allow_url_fopen On',
#    require     => Package[$php_package],
#  }
}