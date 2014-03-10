#
#
class maze::apply inherits maze{

    if ($apply == 'true') {
        cron { 'maze apply':
            ensure  => 'present',
            command => "sudo maze apply",
            user    => "$username",
            minute  => '*/5',
            require => File["$mazeLib/maze-report"]
        }
    } else {
        cron { 'maze apply':
            ensure  => 'absent',
            command => "sudo maze apply",
            user    => "$username",
            minute  => '*/5',
            require => File["$mazeLib/maze-report"]
        }
    }
    

}
