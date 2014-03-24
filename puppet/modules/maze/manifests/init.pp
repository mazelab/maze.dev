# = Class: maze
#
# This is the main maze class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*mazeHost*]
#   where reports are sended
#
# [*nodeId*]
#   ip of this node. Used for node assignment in maze.core
#
# [*user_groups*]
#   sets additional groups of maze user
#
# [*user_notify*]
#   puppet notification on maze user change
#
#
# Default class params - As defined in maze::params.
#
# [*groupname*]
#   maze user group name
#
# [*$homedir*]
#   maze user home dir
#
# [*apply*]
#   enable or disable apply cron for all modules
#
# [*username*]
#   maze user username
#
# [*https*]
#   enable or disable reports and command get with https
#
# == Author
#   CDS-Internetagentur
#
class maze (
    $groupname             = params_lookup( 'groupname' ),
    $user_groups           = params_lookup( 'user_groups' ),
    $user_notify           = params_lookup( 'user_notify' ),
    $homedir               = params_lookup( 'homedir' ),
    $mazeHost              = params_lookup( 'mazeHost' ),
    $nodeIp                = params_lookup( 'nodeIp' ),
    $apply                 = params_lookup( 'apply' ),
    $username              = params_lookup( 'username' ),
    $https                 = params_lookup( 'https' )

) inherits maze::params {

    # user config
    user { $username:
        comment => "maze system user",
        ensure => 'present',
        home    => $homedir,
        shell   => "/bin/bash",
        groups  => $user_groups,
        managehome => true,
        notify => $user_notify,
    }
    group { $groupname:
        require => User[$username],
        ensure => 'present',
    }

    # homedir
    exec { "maze homedir":
        command => "/bin/cp -R /etc/skel $homedir; /bin/chown -R $username:$groupname $homedir",
        creates => $homedir,
        require => User[$username],
    }

    if($mazeHost and $nodeIp) {
        include maze::install
    } else {
        notify{'No mazeHost and/or NodeIp configured... skiped further actions':}
    }
}

