define awesome::vhosts::proxy (
    $domain=$name,
    $server_name=$name,
    $listen_options=undef,
    $rewrite_to_https=true,
    $location_allow=undef,
    $location_deny=undef,
    $proxy=undef,
){
    $certfile = "${::letsencrypt::cert_root}/${server_name}/fullchain.pem"
    $keyfile = "${::letsencrypt::cert_root}/${server_name}/privkey.pem"

    nginx::resource::vhost { $name:
        server_name      => [$server_name],
        listen_options   => $listen_options,
        ssl              => true,
        ssl_key          => $keyfile,
        ssl_cert         => $certfile,
        rewrite_to_https => $rewrite_to_https,
        location_allow   => $location_allow,
        location_deny    => $location_deny,
        proxy            => $proxy,
    }

    # configure letsencrypt
    letsencrypt::domain{ $server_name: }
    nginx::resource::location { "letsencrypt_${name}":
        location       => '/.well-known/acme-challenge',
        vhost          => $name,
        location_alias => $::letsencrypt::www_root,
        ssl            => true,
    }
}
