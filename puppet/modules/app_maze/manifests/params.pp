# Class: app_maze::params
#
# This class defines default parameters used by the main module class app_maze
#
# == Variables
#
# Refer to app_maze class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class app_maze::params
{
    $repository = 'https://github.com/mazelab/maze.core'

    $environment = 'production'
    $owner = 'vagrant'
    $group = 'vagrant'
}