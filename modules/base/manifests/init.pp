class base {
  class { '::firewall': }
  create_resources('firewall', hiera_hash('firewall', {}))
}
