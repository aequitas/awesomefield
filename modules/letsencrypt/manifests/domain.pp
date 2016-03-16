define letsencrypt::domain (
    $domain = $title,
){

    concat::fragment { "letsencrypt_domain_${domain}":
        target  => "${letsencrypt::config_root}/domains.txt",
        content => "${domain}\n",
    }

    file {
        "${letsencrypt::cert_root}/${domain}/":
            ensure  => directory;
    }
    file {
        "${letsencrypt::cert_root}/${domain}/fullchain.pem":
            ensure  => link,
            replace => no,
            target  => "${letsencrypt::cert_root}/placeholders/cert.pem";

        "${letsencrypt::cert_root}/${domain}/privkey.pem":
            ensure  => link,
            replace => no,
            target  => "${letsencrypt::cert_root}/placeholders/key.pem";
    } ~> Service['nginx'] ~> Class['letsencrypt::renew']
}
