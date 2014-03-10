class configure::maze
{
    include configure::php

    class {"composer":
      target_dir      => '/usr/bin',
      composer_file   => 'composer',
      require         => Package['php5']
    }

    phpfpm::nginx::vhost { 'app_maze':
        server_name => '10.33.33.10',
        root        => '/vagrant/src/maze.core/src/public',
        application_env => 'development',
    }

    git::reposync { 'maze.core':
        source_url      => 'https://github.com/mazelab/maze.core',
        destination_dir => '/vagrant/src/maze.core',
        owner   => 'vagrant',
        group   => 'vagrant',
    }

    exec { "make-maze-vendors":
        command => "composer install",
        cwd => "/vagrant/src/maze.core",
        creates => '/vagrant/src/maze.core/src/vendor',
        require => [Class['composer'], Git::Reposync['maze.core']]
    }

}