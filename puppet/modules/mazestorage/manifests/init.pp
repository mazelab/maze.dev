class mazestorage() inherits mazestorage::params {
    include mazestorage::scripts

    class{ "openssh":
        template => 'mazestorage/sshd.conf'
    }
}
