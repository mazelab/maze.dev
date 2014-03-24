# = Class: maze_storage
#
# This class deploys maze storage scripts
#
# == Requires
#   maze (puppet)
#
# == Author
#   CDS-Internetagentur
#
class maze_storage inherits maze_storage::params
{
    maze::script{ "storage/maze-report":
        content => template("$module_name/script-head.erb", "$module_name/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/storage",
        target  => "maze-report"
    }

    maze::script{ "storage/maze-client":
        content => template("$module_name/script-head.erb", "$module_name/maze-client.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/storage",
        target  => "maze-client"
    }
}
