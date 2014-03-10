#   
#
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

