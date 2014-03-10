#
#
#
class mazevpopqmail::qmail::init inherits mazevpopqmail::qmail::params {
    include mazevpopqmail::qmail::install
    include mazevpopqmail::qmail::configure
    include mazevpopqmail::qmail::courier

    service { "qmail":
        enable      => "true",
        ensure      => "running",
        hasrestart  => "true",
        hasstatus   => "false",
        status      => "/etc/init.d/qmail stat",
        require     =>  [File["link qmail service script"]]
    }

     service { "svscanboot":
        enable      => "true",
        ensure      => "running",
        require     => [Exec["build daemontools"]]
    }

    service { "authdaemon":
        name        => "courier-authdaemon",
        enable      => "true",
        ensure      => "running",
        hasrestart  => "true",
        hasstatus   => "false",
        status      => "ps -ef | grep authdaemond | grep -v grep"
    }

     service { "courier-imap":
        enable      => "true",
        ensure      => "running",
        require     => [Package["imap-ssl"]]
    }

    service { "courier-pop":
        enable      => "true",
        ensure      => "running",
        require     => [Package["pop-ssl"]]
    }

    service { "rsyslog":
        enable      => "true",
        ensure      => "running"
    }

    service { "spamassassin":
        enable      => "true",
        ensure      => "running",
        hasstatus   => "true",
        require     => [Service["qmail"]]
    }

    service { "postfix":
        enable      => "false",
        ensure      => "stopped",
        require     => [Package["imap-ssl"]]
    }

}
