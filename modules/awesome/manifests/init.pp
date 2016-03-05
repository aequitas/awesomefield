class awesome {
    create_resources('awesome::maillist', hiera_hash('maillists', {}))
    create_resources('awesome::vhost', hiera_hash('awesome::vhosts', {}))

    class { 'letsencrypt': }

    class { 'opendkim': }
    opendkim::socket { 'opendkim default': }
    Package['opendkim'] ->
    opendkim::domain { 'awesomeretro.org':
        private_key_source => 'puppet:///modules/awesome/awesomeretro.org.mail._domainkey.key',
    }
}
