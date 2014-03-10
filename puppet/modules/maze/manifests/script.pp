define maze::script (
    $content = false,
    $source = false,
    $fork = false,
    $path = false,
    $target = false
){
    if !($content or $source or $fork or $path or $target) {
        fail 'invalid argument for maze::script'
    }
    if ($content and $source) {
        fail 'Please provide either $source OR $content'
    }

    if (!defined(File["$fork"])) {
        file { "$fork":
            mode    => 750,
            ensure  => present,
            owner   => "$maze::username",
            group   => "$maze::groupname",
            content => template("${module_name}/fork.erb")
        }

        file_line { "fork sudoers":
            path    => "/etc/sudoers",
            line    => "$maze::username ALL=NOPASSWD: $fork",
        }
    }

    if $content {
        if (!defined(File["$path"])) {
            file { "$path":
                ensure	=> directory,
                mode	=> 0750,
                force	=> true,
                owner   => "$maze::username",
                group   => "$maze::groupname",
                require => File["$fork"]
            }
        }

        file { "$path/$target":
            ensure  => file,
            mode    => 0750,
            force   => true,
            owner   => "$maze::username",
            group   => "$maze::groupname",
            content => "$content",
            require => [File["$fork"], File["$path"]]
        }
    } else {
        file { "$path/$target":
            ensure  => directory,
            mode    => 0750,
            recurse => true,
            force   => true,
            owner   => "$maze::username",
            group   => "$maze::groupname",
            source  => "$source",
            require => File["$fork"]
        }
    }

}
