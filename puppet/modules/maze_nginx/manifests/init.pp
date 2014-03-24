# = Class: maze_nginx
#
# This class deploys maze nginx scripts
#
# == Requires
#   maze (puppet)
#
# == Author
#   CDS-Internetagentur
#
class maze_nginx inherits maze_nginx::params
{
    maze::script{ "nginx/maze-report":
        content => template("$module_name/script-head.erb", "$module_name/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/nginx",
        target  => "maze-report"
    }

    maze::script{ "nginx/maze-vhost":
        content => template("$module_name/script-head.erb", "$module_name/maze-vhost.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/nginx",
        target  => "maze-vhost"
    }
}
