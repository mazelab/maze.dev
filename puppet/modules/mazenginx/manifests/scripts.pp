class mazenginx::scripts inherits mazenginx {

    maze::script{ "nginx/maze-report":
        content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/nginx",
        target  => "maze-report"
    }

    maze::script{ "nginx/maze-vhost":
        content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-vhost.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/nginx",
        target  => "maze-vhost"
    }

}
