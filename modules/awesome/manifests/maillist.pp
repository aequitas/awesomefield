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
    value    => 1,
  }
  mailman::list_config { "${name}, member overview only for members":
    mlist    => $name,
    variable => 'private_roster',
    value    => 1,
  }
}
