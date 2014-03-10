#
#
#
class mazevpopqmail::qmail::courier inherits mazevpopqmail::qmail::params
{
    Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/local/bin/", "/usr/sbin/"] }

    if (!defined(Package["imap-ssl"])) {
        package { "imap-ssl":
            name        => "courier-imap-ssl",
            ensure      => "present",
            require     => [Exec["finalizing qmail"], Package["pop-ssl"]]
        }
    }

    if (!defined(Package["pop-ssl"])) {
        package { "pop-ssl":
            name        => "courier-pop-ssl",
            ensure      => "present",
            require     => [Exec["finalizing qmail"]]
        }
    }

    if (!defined(Package["authlib"])) {
        package { "authlib":
            name        => "courier-authlib",
            ensure      => "present",
            require     => [Exec["finalizing qmail"]]
        }
    }

    file { "apply pop3 configuration":
        content     => template("$module_name/qmail/courier.pop3d.erb"),
        path        => "/etc/courier/pop3d",
        notify      => [Service["courier-pop"]],
        require     => [Package["pop-ssl"]]
    }

    file { "libauthvchkpw to authlib":
        path        => "/usr/lib/courier-authlib/libauthvchkpw.so",
        ensure      => "present",
        source      => "puppet:///modules/mazevpopqmail/authlib/libauthvchkpw.so",
        require     => [Package["imap-ssl", "authlib"]]
    }

    file { "apply authdaemon config":
        content     => template("$module_name/qmail/authdaemonrc.erb"),
        path        => "/etc/courier/authdaemonrc",
        notify      => [Service["authdaemon"]],
        require     => [File["libauthvchkpw to authlib"]]
    }

    exec { "imap ssl certificate":
        onlyif      => "test -f /usr/sbin/mkimapdcert &&
                        test -f /etc/courier/imapd.pem",
        creates     => "/usr/lib/courier/imapd.pem",
        command     => "sh /usr/lib/courier/mkimapdcert
                        mv -f /usr/lib/courier/imapd.pem /etc/courier/imapd.pem",
        notify      => [Service["courier-imap"]]
    }

    file { "apply ssl certificate parameters":
        content     => template("$module_name/qmail/courier.imap.cnf.erb"),
        path        => "/etc/courier/imapd.cnf",
        notify      => [Exec["imap ssl certificate", "generate certificate"]],
        require     => [Package["imap-ssl"]]
    }

    file { "apply pop3 ssl configuration":
        content     => template("$module_name/qmail/courier.pop3d-ssl.erb"),
        path        => "/etc/courier/pop3d-ssl",
        notify      => [Service["courier-pop"]],
        require     => [Package["pop-ssl"]]
    }

    file { "apply imap ssl configuration":
        content     => template("$module_name/qmail/courier.imap-ssl.erb"),
        path        => "/etc/courier/imapd-ssl",
        notify      => [Service["courier-pop"]],
        require     => [Package["pop-ssl"]]
    }

}
