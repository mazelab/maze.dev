#
# This definition creates a virtual host
#
# Parameters:
#   [*ensure*]           - Enables or disables the specified vhost (present|absent)
#   [*listen_ip*]        - Default IP Address for NGINX to listen with this vHost on. Defaults to all interfaces (*)
#   [*listen_port*]      - Default IP Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*ipv6_enable*]      - BOOL value to enable/disable IPv6 support (false|true). Module will check to see if IPv6
#                          support exists on your system before enabling.
#   [*ipv6_listen_ip*]   - Default IPv6 Address for NGINX to listen with this vHost on. Defaults to all interfaces (::)
#   [*ipv6_listen_port*] - Default IPv6 Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*default_server*]   - BOOL value to mark this server as default server which is choosen if no hostname is given on the request.
#                          Default: false. Example: default_server => 'true'
#   [*index_files*]      - Default index files for NGINX to read when traversing a directory
#   [*proxy*]            - Proxy server(s) for the root location to connect to.  Accepts a single value, can be used in
#                          conjunction with mazenginx::resource::upstream
#   [*proxy_read_timeout*] - Override the default the proxy read timeout value of 90 seconds
#   [*proxy_set_header*] - Various Header Options
#   [*ssl*]              - Indicates whether to setup SSL bindings for this vhost. (present|absent)
#   [*ssl_cert*]         - Pre-generated SSL Certificate file to reference for SSL Support. This is not generated by this module.
#   [*ssl_key*]          - Pre-generated SSL Key file to reference for SSL Support. This is not generated by this module.
#   [*www_root*]         - Specifies the location on disk for files to be read from. Cannot be set in conjunction with $proxy
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  mazenginx::resource::vhost { 'test2.local':
#    ensure   => present,
#    www_root => '/var/www/nginx-default',
#    ssl      => present,
#    ssl_cert => '/tmp/server.crt',
#    ssl_key  => '/tmp/server.pem',
#  }
define mazenginx::resource::vhost(
  $ensure              = present,
  $listen_ip           = '*',
  $listen_port         = '80',
  $ssl_listen_ip       = '*',
  $ssl_listen_port     = '443',
  $ipv6_enable         = false,
  $ipv6_listen_ip      = '::',
  $ipv6_listen_port    = '80',
  $default_server      = false,
  $server_name         = $name,
  $ssl                 = absent,
  $ssl_only            = false,
  $ssl_cert            = undef,
  $ssl_client_cert     = undef,
  $ssl_verify_client   = undef,
  $ssl_key             = undef,
  $proxy               = undef,
  $proxy_read_timeout  = '90',
  $proxy_set_header    = undef,
  $proxy_redirect      = undef,
  $index_files         = ['index.html', 'index.htm', 'index.php'],
  $template_header     = 'nginx/vhost/vhost_header.erb',
  $template_fastcgi    = 'nginx/vhost/vhost_fastcgi.erb',
  $template_footer     = 'nginx/vhost/vhost_footer.erb',
  $template_ssl_header = 'nginx/vhost/vhost_ssl_header.erb',
  $template_ssl_footer = 'nginx/vhost/vhost_footer.erb',
  $template_ssl_proxy  = 'nginx/vhost/vhost_location_proxy.erb',
  $template_proxy      = 'nginx/vhost/vhost_location_proxy.erb',
  $template_directory  = 'nginx/vhost/vhost_location_directory.erb',
  $www_root            = undef,
  $create_www_root     = false,
  $owner               = '',
  $groupowner          = '',
  $fastcgi             = absent
) {

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx']
  }

  include nginx
  include mazenginx::params

  $bool_ssl_only = any2bool($ssl_only)

  $real_owner = $owner ? {
    ''      => $mazenginx::process_user,
    default => $owner,
  }

  $real_groupowner = $groupowner ? {
    ''      => $mazenginx::process_user,
    default => $groupowner,
  }

  $file_real = "${mazenginx::vdir}/${name}.conf"

  # Some OS specific settings:
  # On Debian/Ubuntu manages sites-enabled
  case $::operatingsystem {
    ubuntu,debian,mint: {

      $manage_file = $ensure ? {
        present => link,
        absent  => absent,
      }

      file { "${mazenginx::config_dir}/sites-enabled/${name}.conf":
        ensure  => $manage_file,
        target  => $file_real,
        require => [Package['nginx'], File[$file_real], ],
        notify  => Service['nginx'],
      }
    }
    redhat,centos,scientific,fedora: {
      # include mazenginx::redhat
    }
    default: { }
  }


  concat { $file_real: }

  # Add IPv6 Logic Check - Nginx service will not start if ipv6 is enabled
  # and support does not exist for it in the kernel.
  if ($ipv6_enable == true) and ($ipaddress6)  {
    warning('nginx: IPv6 support is not enabled or configured properly')
  }

  # Check to see if SSL Certificates are properly defined.
  if ($ssl == present) {
    if ($ssl_cert == undef) or ($ssl_key == undef) {
      fail('nginx: SSL certificate/key (ssl_cert/ssl_cert) and/or SSL Private must be defined and exist on the target system(s)')
    }
  }

  # Create the default location reference for the vHost
  mazenginx::resource::location {"${name}-default":
    ensure             => $ensure,
    vhost              => $name,
    ssl                => $ssl,
    ssl_only           => $ssl_only,
    mixin_ssl          => true,
    location           => '/',
    proxy              => $proxy,
    proxy_read_timeout => $proxy_read_timeout,
    proxy_set_header   => $proxy_set_header,
    proxy_redirect     => $proxy_redirect,
    www_root           => $www_root,
    create_www_root    => $create_www_root,
    owner              => $real_owner,
    groupowner         => $real_groupowner,
    notify             => $mazenginx::manage_service_autorestart,
    template_proxy     => $template_proxy,
    template_ssl_proxy => $template_ssl_proxy,
    template_directory => $template_directory,
  }

  # Use the File Fragment Pattern to construct the configuration files.
  # Create the base configuration file reference.

  concat::fragment { "${name}+00.tmp":
    ensure  => $ensure,
    order   => '00',
    content => "# File managed by Puppet\n\n",
    notify  => $mazenginx::manage_service_autorestart,
    target  => $file_real,
  }

  if $bool_ssl_only != true {
    concat::fragment { "${name}+01.tmp":
      ensure  => $ensure,
      order   => '01',
      content => template($template_header),
      notify  => $mazenginx::manage_service_autorestart,
      target  => $file_real,
    }


    concat::fragment { "${name}+68-fastcgi.tmp":
      ensure  => $fastcgi,
      order   => '68',
      content => template($template_fastcgi),
      notify  => $mazenginx::manage_service_autorestart,
      target  => $file_real,
    }

    # Create a proper file close stub.
    concat::fragment { "${name}+69.tmp":
      ensure  => $ensure,
      order   => '69',
      content => template($template_footer),
      notify  => $mazenginx::manage_service_autorestart,
      target  => $file_real,
    }
  }

  # Create SSL File Stubs if SSL is enabled
  concat::fragment { "${name}+70-ssl.tmp":
    ensure  => $ssl,
    order   => '70',
    content => template($template_ssl_header),
    notify  => $mazenginx::manage_service_autorestart,
    target  => $file_real,
  }
  concat::fragment { "${name}+99-ssl.tmp":
    ensure  => $ssl,
    order   => '99',
    content => template($template_footer),
    notify  => $mazenginx::manage_service_autorestart,
    target  => $file_real,
  }
}
