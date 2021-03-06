class awesome (
    $mysql_root_pw=undef,
    $pma_allow=undef,
){
    # enable apt unattended security upgrades
    class { '::apt': }
    class { '::unattended_upgrades': }

    # some utility packages
    package { ['sl', 'atop', 'htop']:
      ensure => latest,
    }

    # enable ntp
    class { '::ntp':
        servers => [
            '0.pool.ntp.org', '1.pool.ntp.org',
            '2.pool.ntp.org', '3.pool.ntp.org'
        ],
    }

    # enable ssh server
    class { '::ssh': }

    # create users
    create_resources(awesome::user, hiera_hash('awesome::users', {}))

    # let sudoers know not to change anything outside of puppet
    file {
        '/etc/sudoers.lecture':
              content => "THIS HOST IS MANAGED BY PUPPET. Please only make permanent changes\nthrough puppet and do not expect manual changes to be maintained!\nMore info: https://github.com/aequitas/awesomefield\n\n";

        '/etc/sudoers.d/lecture':
              content => "Defaults\tlecture=\"always\"\nDefaults\tlecture_file=\"/etc/sudoers.lecture\"\n";
    }

    swap_file::files { 'default':
        ensure   => present,
    }

    # nginx and vhosts
    file { '/var/www/cache':
        ensure => directory,
    } ->
    class {'nginx': }

    # certificates
    class { 'letsencrypt': }

    # php related
    class {'::php::fpm::daemon': }
    create_resources('php::fpm::conf', hiera_hash('php::fpm::config', {}))

    # dbs
    class { '::mysql::server':
        root_password           => $mysql_root_pw,
        remove_default_accounts => true,
    }

    # maillists
    create_resources('awesome::maillist', hiera_hash('maillists', {}))
    class { 'opendkim': }
    opendkim::socket { 'opendkim default': }
    Package['opendkim'] ->
    opendkim::domain { 'awesomeretro.org':
        private_key_content => hiera('dkim::private_key'),
    }
    awesome::vhosts::proxy { 'lists.awesomeretro.org':
        proxy => 'http://127.0.0.1:8081',
    }
    nginx::resource::location { 'icons':
        location       => "~ \"^(/doc/mailman/images|/images/mailman)/(.*(png|jpg|gif))\$\"",
        vhost          => 'lists.awesomeretro.org',
        location_alias => "/usr/share/images/mailman/\$2",
        ssl            => true,
    }


    # phpmyadmin
    File['/var/www/phpmyadmin/html/'] ->
    class { 'phpmyadmin':
        path    => '/var/www/phpmyadmin/html/pma',
        user    => 'www-data',
        servers => [
            {
                desc => 'local',
                host => '127.0.0.1',
            },
        ],
    }
    vhosts::php{'phpmyadmin':
        server_name    => 'phpmyadmin.awesomnia.awesomeretro.org',
        location_allow => $pma_allow,
        location_deny  => ['all'],
    }
}
