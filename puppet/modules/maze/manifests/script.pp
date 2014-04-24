# = Class: maze::script
#
# This class is used to deploy a maze script
#
#
# == Parameters
#
#
# Default class params - As defined in maze::params.
#
# [*content*]
#    set maze script content directly
#
# [*source*]
#   set maze script content over puppet source
#
# [*fork*]
#   file path of fork script which calls other maze scripts
#
# [*path*]
#   maze script base path
#
# [*target*]
#   maze script file path relative to path (basepath)
#
# == Author
#   CDS-Internetagentur
#
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
            owner   => "root",
            group   => "root",
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
                owner   => "root",
                group   => "root",
                require => File["$fork"]
            }
        }

        file { "$path/$target":
            ensure  => file,
            mode    => 0750,
            force   => true,
            owner   => "root",
            group   => "root",
            content => "$content",
            require => [File["$fork"], File["$path"]]
        }
    } else {
        file { "$path/$target":
            ensure  => directory,
            mode    => 0750,
            recurse => true,
            force   => true,
            owner   => "root",
            group   => "root",
            source  => "$source",
            require => File["$fork"]
        }
    }

}
