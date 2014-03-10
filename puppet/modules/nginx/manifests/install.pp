class nginx::install {
	
	package { 'nginx':
		ensure => installed,
	}
	
	file {
	  '/etc/nginx/nginx.conf':
      ensure => present,
      content => template('nginx/nginx.conf.erb'),
      require => Package['nginx'],
      notify => Service['nginx']
	}
	
}