# define: mazenginx::resource::upstream
#
# This definition creates a new upstream proxy entry for NGINX
#
# Parameters:
#   [*ensure*]      - Enables or disables the specified location (present|absent)
#   [*members*]     - Array of member URIs for NGINX to connect to. Must follow valid NGINX syntax.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  mazenginx::resource::upstream { 'proxypass':
#    ensure  => present,
#    members => [
#      'localhost:3000',
#      'localhost:3001',
#      'localhost:3002',
#    ],
#  }
define mazenginx::resource::upstream (
  $members,
  $ensure            = present,
  $template_upstream = 'nginx/conf.d/upstream.erb',
) {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $real_file = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  file { "${mazenginx::cdir}/${name}-upstream.conf":
    ensure   => $real_file,
    content  => template($template_upstream),
    notify   => $mazenginx::manage_service_autorestart,
    require  => Package['nginx'],
  }
}
