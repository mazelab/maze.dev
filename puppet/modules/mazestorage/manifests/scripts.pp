class mazestorage::scripts inherits mazestorage {

    maze::script{ "storage/maze-report":
        content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-report.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/storage",
        target  => "maze-report"
    }

    maze::script{ "storage/maze-client":
        content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-client.erb"),
        fork    => "$forkPath",
        path    => "$mazeLib/storage",
        target  => "maze-client"
    }

}
