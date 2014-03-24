# = Class: vpopqmail::qmail::configure
#
# This class sets services and calls all install dependancies
#
# == Author
#   CDS-Internetagentur
#
class vpopqmail::qmail::init inherits vpopqmail {
    include vpopqmail::qmail::install
    include vpopqmail::qmail::configure
    include vpopqmail::qmail::courier

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
