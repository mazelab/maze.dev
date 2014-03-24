# = Class: maze::install
#
# This class initializes/installs maze dependancies on the node
#
#
# == Author
#   CDS-Internetagentur
#
class maze::install inherits maze{

    if (!defined(Package['curl'])) {
        package { "curl":
            ensure => 'latest',
        }
    }

    file{ "$configPath":
        ensure  => present,
        content => template("$module_name/maze.cfg"),
        owner   => 'maze',
        require => [Exec['maze homedir']]
    }

    # deploy core scripts
    maze::script { "maze-api":
        content => template("$module_name/script-head.erb", "$module_name/maze-api.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib",
        target  => "maze-api"
    }
    maze::script { "maze-report":
        content => template("$module_name/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib",
        target  => "maze-report"
    }
    maze::script { "maze-modules":
        content => template("$module_name/maze-modules.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib",
        target  => "maze-modules"
    }
    maze::script { "maze-commands":
        content => template("$module_name/maze-commands.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib",
        target  => "maze-commands"
    }
    maze::script { "maze-apply":
        content => template("$module_name/maze-apply.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib",
        target  => "maze-apply"
    }

    # build api key
    file{ "$homedir/api":
        ensure => 'directory',
        require => [Exec['maze homedir']]
    }
    file{ "$homedir/api/key":
        ensure => 'present',
        group => "$groupname",
        owner => "$username",
        require => File["$homedir/api"],
    }
    exec{ "create maze api key":
        path    => "/usr/local/bin/:/usr/bin:/bin:/usr/sbin",
        command => "sudo maze api key generate",
        user => "$username",
        unless => "maze api key",
        require => [File["$homedir/api/key"], File["$mazeLib/maze-api"]]
    }

    if ($apply == 'true') {
        cron { 'maze apply':
            ensure  => 'present',
            command => "sudo maze apply",
            user    => "$username",
            minute  => '*/5',
            require => File["$mazeLib/maze-report"]
        }
    } else {
        cron { 'maze apply':
            ensure  => 'absent',
            command => "sudo maze apply",
            user    => "$username",
            minute  => '*/5',
            require => File["$mazeLib/maze-report"]
        }
    }
    
}
