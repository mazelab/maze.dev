# = Class: maze_vpopqmail
#
# This class deploys maze vpopqmail scripts
#
# == Requires
#   maze (puppet)
#
# == Author
#   CDS-Internetagentur
#
class maze_vpopqmail(
    $vpopmail_homedir      = params_lookup( 'vpopmail_homedir' )
) inherits maze_vpopqmail::params {

    maze::script { "vpopqmail/maze-report":
        content => template("$module_name/script-head.erb", "$module_name/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-report"
    }
    maze::script { "vpopqmail/maze-domain":
        content => template("$module_name/script-head.erb", "$module_name/maze-domain.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-domain"
    }
    maze::script { "vpopqmail/maze-account":
        content => template("$module_name/script-head.erb", "$module_name/maze-account.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-account"
    }
    maze::script { "vpopqmail/maze-forwarder":
        content => template("$module_name/script-head.erb", "$module_name/maze-forwarder.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-forwarder"
    }
    maze::script { "vpopqmail/maze-catchall":
        content => template("$module_name/script-head.erb", "$module_name/maze-catchall.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-catchall"
    }
    maze::script { "vpopqmail/maze-robot":
        content => template("$module_name/script-head.erb", "$module_name/maze-robot.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-robot"
    }
    maze::script { "vpopqmail/maze-list":
        content => template("$module_name/script-head.erb", "$module_name/maze-list.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/vpopqmail",
        target  => "maze-list"
    }
}

