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
              content => "THIS HOST IS MANAGED BY PUPPET. PLEASE ONLY MAKE PERMANENT CHANGES\nTHROUGH PUPPET AND DO NOT EXPECT MANUAL CHANGES TO BE MAINTAINED.\n\n";

        '/etc/sudoers.d/lecture':
              content => "Defaults\tlecture=\"always\"\nDefaults\tlecture_file=\"/etc/sudoers.lecture\"\n";
    }

    swap_file::files { 'default':
        ensure   => present,
    }

    # nginx and vhosts
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
