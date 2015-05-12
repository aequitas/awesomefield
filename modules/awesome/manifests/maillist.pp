define awesome::maillist (
  $description = '',
  $admin       = hiera('awesome::maillist::admin'),
  $password    = hiera('awesome::maillist::password'),
  $webserver   = 'lists.$::fqdn',
  $mailserver  = $::fqdn,
){
  maillist { $name:
    ensure      => present,
    description => $description,
    admin       => $admin,
    password    => $password,
    webserver   => $webserver,
    mailserver  => $mailserver,

  }
}
