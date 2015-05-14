define awesome::maillist (
  $description = '',
  $admin       = hiera('awesome::maillist::admin'),
  $password    = hiera('awesome::maillist::password'),
  $webserver   = $::mailman::http_hostname,
  $mailserver  = $::mailman::smtp_hostname,
){
  maillist { $name:
    ensure      => present,
    description => $description,
    admin       => $admin,
    password    => $password,
    webserver   => $webserver,
    mailserver  => $mailserver,
  }

  mailman::list_config { "${name}, archives only for members":
    mlist    => $name,
    variable => 'archive_private',
    value    => '1',
  }
  mailman::list_config { "${name}, member overview only for members":
    mlist    => $name,
    variable => 'private_roster',
    value    => '1',
  }
  mailman::list_config { "${name}, new members should confirm their address and admin should aprove":
    mlist    => $name,
    variable => 'subscribe_policy',
    value    => '3',
  }
  mailman::list_config { "${name}, hostname for this mailing list":
    mlist    => $name,
    variable => 'host_name',
    value    => "'${mailserver}'",
  }
}
