#
#
class maze::user inherits maze{

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

}

