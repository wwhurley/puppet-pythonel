class pythonel::interpreter::rh-python34-scl {

    $interpreter = 'rh-python34-scl'
    $bindir      = '/opt/rh/rh-python34/root/usr/bin'
    $packages    = ['rh-python34', 'rh-python34-python-devel', 'rh-python34-python-pip', 'rh-python34-python-virtualenv']

    #
    # Only change if binaries are not called python, pip or virtualenv
    #
    $python          = "$bindir/python"
    $pip             = "$bindir/pip"
    $virtualenv      = "$bindir/virtualenv"
    $extra_pip_args  = ""
    $base_script_dir = ""


    #
    # Hardly need any changes from here..
    #
    $upgrade_pip            = hiera("pythonel::interpreter::${interpreter}::upgrade_pip", false)
    $upgrade_virtualenv     = hiera("pythonel::interpreter::${interpreter}::upgrade_virtualenv", false)
    $packages_ensure        = hiera("pythonel::interpreter::${interpreter}::packages_ensure", 'present')
    $pip_config_file        = hiera("pythonel::interpreter::${interpreter}::pip_config_file", '')
    $global_pip_config_file = hiera("pythonel::interpreter::pip_config_file", '')


    ################################
    # YumRepo and package handling #
    # Adapt to your needs          #
    ################################
    realize Swrepo::Repo['rhel-server-rhscl-6-rpms']
    package { $packages:
        ensure => $packages_ensure,
    }
    ####################################
    # Packages should now be installed #
    ####################################

    anchor { "$interpreter":
        require => Package[$packages]
    }

    $_pip_config_file = $pip_config_file ? {
        ''       => $global_pip_config_file,
        default  => $pip_config_file
    }
    $environment = $_pip_config_file ? {
        ''      => [],
        default => [ "PIP_CONFIG_FILE=$_pip_config_file"]
    }

    include pythonel::interpreter::prep # Define pythonel_helper

    if $upgrade_pip {
        exec { "upgrade-pip-$interpreter":
            command     => "/usr/local/bin/pythonel_helper $pip install --upgrade pip",
            environment => $environment,
            unless      => "/usr/local/bin/pythonel_helper $pip install --upgrade pip |grep 'Requirement already up-to-date: pip'",
            require     => [File['pythonel_helper'], Package[$packages]]
        }
    }
    if $upgrade_virtualenv {
        exec { "upgrade-virtualenv-$interpreter":
            command     => "/usr/local/bin/pythonel_helper $pip install --upgrade virtualenv",
            environment => $environment,
            unless      => "/usr/local/bin/pythonel_helper $pip install --upgrade virtualenv |grep 'Requirement already up-to-date: virtualenv'",
            require     => [File['pythonel_helper'], Package[$packages]]
        }
    }


}
