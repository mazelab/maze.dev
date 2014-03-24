# Class: maze_nginx::params
#
# This class defines default parameters used by the main module class maze_nginx
#
# == Variables
#
# Refer to maze_nginx class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class maze_nginx::params inherits maze
{

  $report = true
  $command_status = 'service nginx status'
  $command_configtest = 'nginx -t -q'
  $command_reload = 'nginx -s reload'

}
