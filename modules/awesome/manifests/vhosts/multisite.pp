define awesome::vhosts::multisite (
    $domain=$name,
    $webroot="/var/www/${name}/html/",
    $server_name=$name,
    $listen_options='',
    $ipv6_listen_options='',
    $rewrite_to_https=false,
    $subdomains=[],
){
    if $server_name == '_' {
        $le_server_name = $name
        $le_subdomains = $subdomains
        $server_names = [$name]
    } else {
        $le_server_name = $server_name
        $le_subdomains = concat(['www'], $subdomains)
        $server_names = concat([
            $server_name,
            "www.${server_name}"
          ],
          suffix($subdomains, ".${name}")
        )
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
        server_name         => $server_names,
        www_root            => $multisite_webroot,
        index_files         => ['index.php'],
        try_files           => ["\$uri", "\$uri/", '/index.php?$args'],
        listen_options      => $listen_options,
        ipv6_listen_options => $ipv6_listen_options,
        ipv6_enable         => true,
        ssl                 => true,
        ssl_key             => $keyfile,
        ssl_cert            => $certfile,
        rewrite_to_https    => $rewrite_to_https,
    }

    nginx::resource::location { $name:
        vhost               => $name,
        ssl                 => true,
        www_root            => $multisite_webroot,
        location            => '~ \.php$',
        fastcgi_params      => '/etc/nginx/fastcgi_params',
        fastcgi             => 'multisite',
        try_files           => ['$uri', '$uri/', '/index.php?$args'],
        location_cfg_append => {
            'fastcgi_cache'        => 'd3',
            'fastcgi_cache_valid'  => '200 5m',
            'fastcgi_cache_bypass' =>"\$cookie_nocache \$wordpress_nocache \$arg_nocache",
        },
        raw_append          => "if (\$http_cookie ~* \"wordpress_logged_in_\"){ set \$wordpress_nocache 1; }",
    }

    nginx::resource::location { "static_${name}":
        vhost               => $name,
        ssl                 => true,
        www_root            => $multisite_webroot,
        location            => '~* \.(js|css|png|jpg|jpeg|gif|ico).*$',
        location_cfg_append => {
            'expires' => '1w',
        },
    }

    # configure letsencrypt
    letsencrypt::domain{ $le_server_name:
        subdomains => $le_subdomains,
    }
    nginx::resource::location { "letsencrypt_${name}":
        location       => '/.well-known/acme-challenge',
        vhost          => $name,
        location_alias => $::letsencrypt::www_root,
        ssl            => true,
    }
}
