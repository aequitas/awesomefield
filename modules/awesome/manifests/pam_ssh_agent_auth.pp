# allow sudo authentication based on ssh authorized keys in /etc/sudo_ssh_authorized_keys
class awesome::pam_ssh_agent_auth {
  apt::ppa { 'ppa:cpick/pam-ssh-agent-auth': } ->

  package { 'pam-ssh-agent-auth':
    ensure  => latest,
  }

  file { '/etc/pam.d/sudo':
    source => 'puppet:///modules/awesome/pam_ssh_agent_auth/sudo.pam',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { '/etc/sudo_ssh_authorized_keys':
    ensure => directory,
  }
}
