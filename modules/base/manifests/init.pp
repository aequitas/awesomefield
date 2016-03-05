class base {
    class { '::firewall': }
    create_resources('firewall', hiera_hash('firewall', {}))
    create_resources('host', hiera_hash('hosts', {}))

    Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }
}
