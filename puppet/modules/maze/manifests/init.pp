# Class: maze
#
#
class maze (
    $groupname             = params_lookup( 'groupname' ),
    $user_groups           = params_lookup( 'user_groups' ),
    $user_notify           = params_lookup( 'user_notify' ),
    $homedir               = params_lookup( 'homedir' ),
    $mazeHost              = params_lookup( 'mazeHost' ),
    $nodeIp                = params_lookup( 'nodeIp' ),
    $apply                = params_lookup( 'apply' ),
    $username              = params_lookup( 'username' ),
    $https                 = params_lookup( 'https' )

) inherits maze::params {

    # init maze user
    include maze::user

    if($mazeHost and $nodeIp) {
        # init maze core functionality
        include maze::core

        include maze::apply
    } else {
        notify{'No mazeHost and/or NodeIp configured... skiped further actions':}
    }
}

