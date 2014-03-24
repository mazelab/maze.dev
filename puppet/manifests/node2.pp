Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# Run apt-get update when anything beneath /etc/apt/ changes
exec { 
    "apt-get update":
        command => "/usr/bin/apt-get update",
        onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}
Exec["apt-get update"] -> Package <| |>

package { ['mc']:
    ensure => latest,
}

class { 'maze':
    nodeIp=> '10.33.33.12',
    mazeHost => '10.33.33.10'
}

class { 'mongodb':
    use_10gen => true
}

class{ "openssh":
    template => 'configure/sshd.maze-storage.conf'
}

class { ['nginx', 'vpopqmail', 'maze_mongodb', 'maze_nginx', 'maze_storage', 'maze_vpopqmail']: }