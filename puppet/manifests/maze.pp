Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# Run apt-get update when anything beneath /etc/apt/ changes
exec { 
    "apt-get update":
        command => "/usr/bin/apt-get update",
        onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}
Exec["apt-get update"] -> Package <| |>

class { ['git', 'mongodb', 'configure::maze', 'configure::rockmongo']: }