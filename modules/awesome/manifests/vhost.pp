define awesome::vhost(

){
    $domains = [$name, "www.${title}"]

    $webroot = "/var/www/${title}"

    file {$webroot:
        ensure => directory,
    } ->

    nginx::resource::vhost { $server_name:
        server_name      => $domains,
        # rewrite_to_https => true,
        www_root         => $webroot,
        # ssl              => true,
        # ssl_key          => "/etc/letsencrypt/live/${title}/privkey.pem",
        # ssl_cert         => "/etc/letsencrypt/live/${title}/fullchain.pem",
    }
    #  ->
    #
    # letsencrypt::certonly { $title:
    #     webroot_paths => [$webroot],
    #     plugin        => webroot,
    # }
}
