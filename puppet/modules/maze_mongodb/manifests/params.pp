# Class: maze_mongodb::params
#
# This class defines default parameters used by the main module class maze_mongodb
#
# == Variables
#
# Refer to maze_mongodb class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class maze_mongodb::params inherits maze
{

    $admin_user = ''
    $admin_pwd = ''
    $admin_db = ''

}
