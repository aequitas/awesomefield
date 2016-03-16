define awesome::vhosts::multisite (
    $domain=$name,
    $webroot="/var/www/${name}/html/",
    $server_name=$name,
    $listen_options=undef,
    $rewrite_to_https=true,
){
    $le_server_name = $server_name ? {
        '_'     => $name,
        default => $server_name,
    }
    $certfile = "${::letsencrypt::cert_root}/${le_server_name}/fullchain.pem"
    $keyfile = "${::letsencrypt::cert_root}/${le_server_name}/privkey.pem"

    $multisite_webroot = '/var/www/multisite/html/'

    Class['letsencrypt'] ->
    file {
        "/var/www/${name}/":
            ensure => directory,
            owner  => www-data,
            group  => www-data;
        $webroot:
            ensure => directory,
            owner  => www-data,
            group  => www-data;
    } ->
    nginx::resource::vhost { $name:
        server_name      => [$server_name],
        www_root         => $multisite_webroot,
        index_files      => ['index.php'],
        try_files        => ["\$uri", "\$uri/", '/index.php?$args'],
        listen_options   => $listen_options,
        ssl              => true,
        ssl_key          => $keyfile,
        ssl_cert         => $certfile,
        rewrite_to_https => $rewrite_to_https,
    }

    nginx::resource::location { $name:
        vhost          => $name,
        ssl            => true,
        www_root       => $multisite_webroot,
        location       => '~ \.php$',
        fastcgi_params => '/etc/nginx/fastcgi_params',
        fastcgi        => 'multisite',
        try_files      => ['$uri', '$uri/', '/index.php?$args'],
    }

    # configure letsencrypt
    letsencrypt::domain{ $le_server_name: }
    nginx::resource::location { "letsencrypt_${name}":
        location       => '/.well-known/acme-challenge',
        vhost          => $name,
        location_alias => $::letsencrypt::www_root,
        ssl            => true,
    }
}
