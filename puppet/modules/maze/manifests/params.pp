# Class: maze::params
#
# This class defines default parameters used by the main module class maze
#
# == Variables
#
# Refer to maze class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class maze::params {
    # application settings
    $mazeHost = ''
    $nodeIp = ''
    $apply = 'true'
    $https = 'false'

    # maze user settings
    $username = 'maze'
    $groupname = 'maze'
    $user_groups = []
    $user_notify = []
    $homedir = '/etc/maze'
    $configPath = "$homedir/maze.cfg"
    
    # maze scripting params
    $forkPath = '/usr/bin/maze'
    $mazeLib = '/usr/lib/maze'

}

