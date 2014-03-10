#
#
#
class mazevpopqmail::qmail::configure inherits mazevpopqmail::qmail::params
{
    Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/local/bin/"] }

    exec { "configure hostname $fqdn":
        cwd         => "/usr/src/qmail/qmail-1.03/",
        provider    => "shell",
        unless      => "if ! [ -f /var/qmail/control/me ] || [ $(head -n1 /var/qmail/control/me) != $fqdn ]; then false; fi",
        command     => "sh ./config-fast $fqdn
                       /var/qmail/bin/qmailctl cdb",
        notify      => Service["qmail"],
        require     => [Exec["qmailrocks preinstall script", "finalizing qmail"]]
    }

    exec { "generate certificate":
        cwd         => "/usr/src/qmail/qmail-1.03/",
        creates     => "/var/qmail/control/servercert.pem",
        command     => "openssl req -new -x509 -nodes \
                               -out /var/qmail/control/servercert.pem \
                               -keyout /var/qmail/control/servercert.pem \
                               -subj \"/L=some city/O=some organization/CN=some name\"",
        require     => [Exec["qmailrocks preinstall script", "finalizing qmail"], Package["openssl"]]
    }

    file { "set certificate ownership":
        owner       => "qmaild",
        group       => "qmail",
        mode        => "0640",
        path        => "/var/qmail/control/servercert.pem",
        ensure      => "symlink",
        target      => "/var/qmail/control/clientcert.pem",
        require     => [File["/var/qmail/control/servercert.pem"]]
    }

    file { "set relaying localhost":
        ensure      => present,
        path        => "/etc/tcp.smtp",
        content     => template('mazevpopqmail/qmail/tcp.smtp.relay.erb')
    }

    file { "service directory":
        path        => "/service/",
        ensure      => "directory"
    }
    
    file { "supervise send symlink":
        ensure      => "symlink",
        target      => "/var/qmail/supervise/qmail-send/",
        path        => "/service/qmail-send/",
        require     => [Exec["finalizing qmail"], File["supervise send", "supervise send/log", "service directory"]]
    }
    
    file { "supervise send":
        content     => template("$module_name/qmail/send.erb"),
        path        => "/var/qmail/supervise/qmail-send/run",
        mode        => "0751",
        notify      => [Service["qmail"]],
        require     => [Exec["qmailrocks preinstall script"]]
    }

    file { "supervise send/log":
        content     => template("$module_name/qmail/send_log.erb"),
        path        => "/var/qmail/supervise/qmail-send/log/run",
        mode        => "0751",
        require     => [Exec["qmailrocks preinstall script"]]
    }

    file { "supervise smtpd symlink":
        ensure      => "symlink",
        target      => "/var/qmail/supervise/qmail-smtpd/",
        path        => "/service/qmail-smtpd/",
        require     => [File["supervise smtpd", "supervise smtpd/log", "service directory"]]
    }

    file { "supervise smtpd":
        content     => template("$module_name/qmail/smtpd_run.erb"),
        path        => "/var/qmail/supervise/qmail-smtpd/run",
        mode        => "0751",
        notify      => [Service["qmail"]],
        require     => [Exec["qmailrocks preinstall script"]]
    }

    file { "supervise smtpd/log":
        content     => template("$module_name/qmail/smtpd_log.erb"),
        path        => "/var/qmail/supervise/qmail-smtpd/log/run",
        mode        => "0751",
        require     => [Exec["qmailrocks preinstall script"]]
    }

    file { "apply default rsyslog":
        content     => template("$module_name/qmail/50-default.conf.erb"),
        path        => "/etc/rsyslog.d/50-default.conf",
        notify      => [Service["rsyslog"]]
    }

}
