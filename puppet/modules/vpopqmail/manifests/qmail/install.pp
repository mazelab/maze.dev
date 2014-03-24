# = Class: vpopqmail::qmail::install
#
# This class installs qmail itself
#
# == Author
#   CDS-Internetagentur
#
class vpopqmail::qmail::install inherits vpopqmail
{
    Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/local/bin/", "/usr/sbin/"] }

    if (!defined(Package["patch"])) {
        package { "patch":
            ensure      => "present"
        }
    }

    if (!defined(Package["openssl"])) {
        package { "openssl":
            ensure      => "present",
        }
    }

    if (!defined(Package["pentium-builder"])) {
        package { "pentium-builder":
            ensure      => "present",
            require     => Package["g++"],
        }
    }

    if (!defined(Package["g++"])) {
        package { "g++":
            ensure      => "present",
        }
    }

    if (!defined(Package["make"])) {
        package { "make":
            ensure      => "present",
        }
    }

    if (!defined(Package["wget"])) {
        package { "wget":
            ensure      => "present",
        }
    }

    if (!defined(Package["libssl-dev"])) {
        package { "libssl-dev":
            ensure      => "present",
        }
    }

    exec { "download qmailrocks":
        creates     => "/downloads/qmailrocks.tar.gz",
        command     => "mkdir /downloads/
                        wget http://www.qmailrocks.org/downloads/qmailrocks.tar.gz -P /downloads/"
    }

    exec { "unpack qmailrocks":
        creates     => "/downloads/qmailrocks/",
        cwd         => "/downloads/",
        command     => "tar -zxvf qmailrocks.tar.gz",
        require     => [Exec["download qmailrocks"]]
    }

    exec { "qmailrocks preinstall script":
        unless      => "cat /etc/group | grep nofiles &&
                        cat /etc/group | grep qmail &&
                        ls /var/qmail/supervise/qmail-send/log/ &&
                        ls /var/qmail/supervise/qmail-smtpd/log/ &&
                        ls /usr/src/qmail/qmail-1.03/ ",
        command     => "sh /downloads/qmailrocks/scripts/install/qmr_install_linux-s1.script",
        require     => [Exec["unpack qmailrocks"], Package["make"]]
    }

    exec { "patch qmail source":
        cwd         => "/usr/src/qmail/qmail-1.03/",
        unless      => "ls /usr/src/qmail/qmail-1.03/qmail-1.03-jms1-7.10.patch",
        command     => "wget http://qmail.jms1.net/patches/qmail-1.03-jms1-7.10.patch
                        patch -b < qmail-1.03-jms1-7.10.patch
                        make &&make setup check",
        require     => [Package["patch"], Exec["qmailrocks preinstall script"]]
    }

    exec { "build qmail":
        cwd         => "/usr/src/qmail/qmail-1.03/",
        onlyif      => "ls /usr/src/qmail/qmail-1.03/ | grep base64",
        creates     => "/var/qmail/bin/",
        command     => "make && make setup check",
        notify      => [Exec["configure hostname $fqdn"]],
        require     => [Exec["patch qmail source"], Package["make"]]
    }

    exec { "patch tcpserver":
        cwd         => "/usr/src/qmail/ucspi-tcp-0.88/",
        creates     => "/usr/src/qmail/ucspi-tcp-0.88/error.h.orig",
        command     => "patch -b < /downloads/qmailrocks/patches/ucspi-tcp-0.88.errno.patch",
        require     => [Exec["build qmail"], Package["patch"]]
    }

    exec { "build tcpserver":
        cwd         => "/usr/src/qmail/ucspi-tcp-0.88/",
        creates     => "/usr/local/bin/tcpserver",
        command     => "make && make setup check",
        require     => [Exec["patch tcpserver"], Package["make"]]
    }

    exec { "patch daemontools":
        cwd         => "/package/admin/daemontools-0.76/",
        creates     => "/package/admin/daemontools-0.76/src/error.h.orig",
        command     => "patch -b -dsrc/ < /downloads/qmailrocks/patches/daemontools-0.76.errno.patch",
        require     => [Exec["build qmail"], Package["patch"]]
    }

    exec { "build daemontools":
        cwd         => "/package/admin/daemontools-0.76/",
        creates     => "/usr/local/bin/svscanboot",
        command     => "sh package/install",
        require     => [Exec["patch daemontools"], Package["make"]]
    }

    file { "apply svscanboot":
        content     => template("$module_name/svscanboot.erb"),
        path        => "/etc/init.d/svscanboot",
        mode        => "0751",
        require     => [Exec["build daemontools"]]
    }

    exec { "svscanboot to runlevel":
        unless      => "ls /etc/rc2.d/*svscanboot",
        command     => "update-rc.d svscanboot start 19 2 3 4 5 . stop 20 0 1 6 .",
        require     => [File["apply svscanboot"]]
    }

    exec { "unpack ezmlm":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/ezmlm-0.53-idx-0.41/",
        command     => "tar -zxvf ezmlm-0.53-idx-0.41.tar.gz",
        require     => [Exec["unpack qmailrocks"]]
    }

    exec { "build ezmlm":
        cwd         => "/downloads/qmailrocks/ezmlm-0.53-idx-0.41/",
        creates     => "/usr/local/bin/ezmlm/ezmlmrc",
        command     => "make && make setup",
        require     => [Exec["unpack ezmlm"], Package["make"]]
    }

    exec { "unpack autoresponder":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/autorespond-2.0.5/",
        command     => "tar -zxvf autorespond-2.0.5.tar.gz",
        require     => [Exec["unpack qmailrocks"]]
    }

    exec { "build autoresponder":
        cwd         => "/downloads/qmailrocks/autorespond-2.0.5/",
        creates     => "/usr/bin/autorespond",
        command     => "make && make install",
        require     =>  [Exec["unpack autoresponder"], Package["make"]]
    }

    file { "link autoresponder":
        ensure      => "symlink",
        target      => "/usr/bin/autorespond",
        path        => "/usr/local/bin/autorespond",
        require     => [Exec["build autoresponder"]]
    }

    exec { "download and unpack vpopmail":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/vpopmail-5.4.33/",
        command     => "wget http://sourceforge.net/projects/vpopmail/files/vpopmail-stable/5.4.33/vpopmail-5.4.33.tar.gz
                        tar -vxf vpopmail-5.4.33.tar.gz",
        require     =>  [Exec["unpack autoresponder"], Package["make"]]
    }

    exec { "build vpopmail":
        cwd         => "/downloads/qmailrocks/vpopmail-5.4.33/",
        creates     => "/home/vpopmail/bin/",
        command     => "sh ./configure --enable-qmaildir=/var/qmail/ \
                                --enable-qmail-newu=/var/qmail/bin/qmail-newu \
                                --enable-qmail-inject=/var/qmail/bin/qmail-inject \
                                --enable-qmail-newmrh=/var/qmail/bin/qmail-newmrh \
                                --enable-qmail-ext \
                                --enable-spamassassin=y \
                                --enable-logging=y
                        make && make install-strip",
        require     => [Exec["build qmail", "download and unpack vpopmail"], Package["spamassassin"]]
    }

    exec { "unpack maildrop":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/maildrop-1.6.3/",
        command     => "tar -zxvf maildrop-1.6.3.tar.gz",
        require     =>  [Exec["unpack qmailrocks"]]
    }

    exec { "build maildrop":
        cwd         => "/downloads/qmailrocks/maildrop-1.6.3/",
        creates     => "/usr/local/bin/maildrop",
        command     => "sh ./configure --prefix=/usr/local \
                                       --exec-prefix=/usr/local \
                                       --enable-maildrop-uid=root \
                                       --enable-maildrop-gid=vchkpw \
                                       --enable-maildirquota
                        make && make install-strip",
        require     => [Package["pentium-builder", "make"], Exec["unpack maildrop"]]
    }

    exec { "download cmd5checkpw":
        creates     => "/downloads/cmd5checkpw-0.22.tar.gz",
        command     => "wget tomclegg.net/qmail/cmd5checkpw-0.22.tar.gz -P /downloads/",
    }

    exec { "unpack cmd5checkpw":
        creates     => "/downloads/cmd5checkpw-0.22/",
        command     => "tar -vxf /downloads/cmd5checkpw-0.22.tar.gz -C /downloads/",
        require     => [Exec["download cmd5checkpw"]]
    }

    exec { "build cmd5checkpw":
        cwd         => "/downloads/cmd5checkpw-0.22/",
        creates     => "/bin/cmd5checkpw",
        command     => "make &&cp cmd5checkpw /bin/",
        require     => [Exec["unpack cmd5checkpw"], Package["make"]]
    }

    exec { "finalizing qmail":
        notify      => [File["supervise send", "supervise smtpd"], Exec["remove pop3 service directory"]],
        unless      => "ls /var/qmail/supervise/qmail-send/log/run &&
                        ls /var/qmail/bin/qmailctl",
        command     => "sh /downloads/qmailrocks/scripts/finalize/linux/finalize_linux.script
                        echo \"postmaster@$fqdn\" > /var/qmail/alias/.qmail-postmaster
                        ln -s /var/qmail/alias/.qmail-postmaster /var/qmail/alias/.qmail-mailer-daemon
                        ln -s /var/qmail/alias/.qmail-postmaster /var/qmail/alias/.qmail-root
                        ln -s /var/qmail/alias/.qmail-postmaster /var/qmail/alias/.qmail-anonymous
                        chmod 644 /var/qmail/alias/.qmail*",
        require     =>  [Exec["build tcpserver", "build daemontools", "build maildrop"], File["set relaying localhost"]]
    }

    exec { "remove pop3 service directory":
        notify      => [Service["svscanboot"]],
        onlyif      => "test -d /service/qmail-pop3d/",
        command     => "rm -rf /service/qmail-pop3d",
        require     => [Exec["finalizing qmail"]]
    }

    file { "apply qmail service script":
        content     => template("$module_name/qmailctl.erb"),
        path        => "/var/qmail/bin/qmailctl",
        group       => "qmail",
        mode        => "0755",
        require     => [Exec["finalizing qmail"]]
    }

    file { "link qmail service script":
        ensure      => "symlink",
        target      => "/var/qmail/bin/qmailctl",
        path        => "/etc/init.d/qmail",
        require     => [File["apply qmail service script"]]
    }

    exec { "install qmail init script":
        unless      => "ls /etc/rc2.d/*qmail",
        command     => "update-rc.d qmail start 20 2 3 4 5 . stop 20 0 1 6 .",
        require     => [File["link qmail service script"]]
    }

    file { "link qmail sendmail to /usr/lib/":
        ensure      => "symlink",
        force       => "true",
        target      => "/var/qmail/bin/sendmail",
        path        => "/usr/lib/sendmail",
        require     => [Exec["build qmail"]]
    }

    file { "link qmail sendmail to /usr/sbin/":
        ensure      => "symlink",
        target      => "/var/qmail/bin/sendmail",
        path        => "/usr/sbin/sendmail",
        require     => [Exec["build qmail"]]
    }

    if (!defined(Package["spamassassin"])) {
        package { "spamassassin":
            ensure      => "present"
        }
    }

    if (!defined(Package["procmail"])) {
        package { "procmail":
            ensure      => "present"
        }
    }

    if (!defined(Package["clamav"])) {
        package { "clamav":
            ensure      => "present"
        }
    }

    if (!defined(Package["clamav-daemon"])) {
        package { "clamav-daemon":
            ensure      => "present",
            require     => [Package["clamav"]]
        }
    }

    if (!defined(Package["postfix"])) {
        package { "postfix":
            notify      => [Service["postfix"]],
            ensure      => "present"
        }
    }

    exec { "enable spamassassin":
        onlyif      => "cat /etc/default/spamassassin | grep ENABLED=0",
        command     => "sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/spamassassin",
        require     => [Package["spamassassin"]]
    }

    file { "apply spamassassin defaults":
        notify      => [Service["spamassassin"]],
        content     => template("$module_name/spamd.defaults.erb"),
        path        => "/etc/default/spamassassin",
        require     => [Package["spamassassin"]]
    }

    file { "apply spamassassin configuration":
        notify      => [Service[spamassassin], Exec["build qmail-scanner"]],
        content     => template("$module_name/spamd.local.cf.erb"),
        path        => "/etc/spamassassin/local.cf",
        require     => [Package["spamassassin"]]
    }

    exec { "spamassassin to runlevel":
        unless      => "test -f /etc/rc2.d/*spamassassin",
        command     => "update-rc.d spamassassin start 75 2 3 4 5 .",
        require     => [Package["spamassassin"]]
    }

    exec { "unpack qms-analog":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/qms-analog-0.4.4/",
        command     => "tar -vxf qms-analog-0.4.4.tar.gz ",
        require     => [Exec["finalizing qmail"]]
    }

    exec { "build qms-analog":
        cwd         => "/downloads/qmailrocks/qms-analog-0.4.4/",
        creates     => "/downloads/qmailrocks/qms-analog-0.4.4/qms-analog",
        command     => "make all",
        require     => [Exec["unpack qms-analog"]]
    }

    exec { "unpack qmail-scanner":
        cwd         => "/downloads/qmailrocks/",
        creates     => "/downloads/qmailrocks/qmail-scanner-1.25/",
        command     => "tar -vxf /downloads/qmailrocks/qmail-scanner-1.25.tgz",
        require     => [Exec["finalizing qmail"]]
    }

    exec { "patch qmail-scanner":
        cwd         => "/downloads/qmailrocks/qmail-scanner-1.25/",
        creates     => "/downloads/qmailrocks/qmail-scanner-1.25/qms-config",
        command     => "patch -p1 <  /downloads/qmailrocks/qms-analog-0.4.4/qmail-scanner-1.25-st-qms-20050618.patch",
        require     => [Exec["unpack qmail-scanner", "build qms-analog"]]
    }

    file { "apply qmail-scanner configuration":
        notify      => [Exec["build qmail-scanner"]],
        content     => template("$module_name/qms-config.erb"),
        path        => "/downloads/qmailrocks/qmail-scanner-1.25/qms-config",
        mode        => "0755",
        require     => [Exec["patch qmail-scanner"]]
    }

    exec { "build qmail-scanner":
        notify      => [Exec["qmailscan ownership"]],
        cwd         => "/downloads/qmailrocks/qmail-scanner-1.25/",
        unless      => "test -f /var/qmail/bin/qmail-scanner-queue.pl &&
                        test -d /var/spool/qmailscan/",
        command     => "sh ./qms-config install",
        require     => [ Exec["patch qmail-scanner"], File["apply spamassassin configuration"]]
    }

    exec { "qmailscan ownership":
        unless      => "stat -c \"%G %U\" /var/spool/qmailscan/ | stat -c \"%G %U\" /var/spool/qmailscan/tmp/ | grep \"vchkpw vpopmail\"",
        command     => "chown vpopmail:vchkpw -R /var/spool/qmailscan/",
        require     => [Exec["build qmail-scanner"]]
    }

}
