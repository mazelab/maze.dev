# = Class: maze_mongodb
#
# This class deploys maze mongodb scripts
#
# == Requires
#   maze (puppet)
#
# == Author
#   CDS-Internetagentur
#
class maze_mongodb inherits maze_mongodb::params
{
    maze::script{ "mongodb/maze-report":
      content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-report.erb"),
      fork    => "$forkPath",
      path    => "$mazeLib/mongodb",
      target  => "maze-report"
    }

    maze::script{ "mongodb/maze-database":
      content => template("$module_name/scripts/script-head.erb", "$module_name/scripts/maze-database.erb"),
      fork    => "$forkPath",
      path    => "$mazeLib/mongodb",
      target  => "maze-database"
    }
}
