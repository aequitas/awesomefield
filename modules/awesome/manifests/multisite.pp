class awesome::multisite (
    $db='multisite',
    $db_user='multisite',
    $db_password=undef,
    $db_backup='/var/backups/multisite.sql',
    $multisite_host='awesomnia.awesomeretro.org',
){
    $webroot = '/var/www/multisite/html/'

    ensure_packages(['php5-mysql'])

    # create wordpress DB
    mysql::db { $db:
        user     => $db_user,
        password => $db_password,
        host     => 'localhost',
        grant    => ['SELECT', 'UPDATE'],
        sql      => $db_backup,
    }

    # set WP config for DB settings
    File[$webroot] ->
    file_line {
        'DB_NAME':
            path => "${webroot}/wp-config.php",
            line => "define('DB_NAME', '${db}');",
            match => "define\\('DB_NAME',";
        'DB_USER':
            path => "${webroot}/wp-config.php",
            line => "define('DB_USER', '${db_user}');",
            match => "define\\('DB_USER',";
        'DB_PASSWORD':
            path => "${webroot}/wp-config.php",
            line => "define('DB_PASSWORD', '${db_password}');",
            match => "define\\('DB_PASSWORD',";
    }


    file {$webroot:
        ensure => directory,
        owner  => www-data,
        group  => www-data,
    } ->
    nginx::resource::vhost { 'multisite':
        server_name => ['_'],
        www_root    => $webroot,
        index_files => ['index.php'],
        try_files   => ["\$uri", "\$uri/", 'index.php'],
    } ->

    nginx::resource::upstream { 'multisite':
      members => [
        'unix:/var/run/php5-fpm-multisite.sock',
      ],
    }

    nginx::resource::location { 'multisite':
        vhost          => 'multisite',
        www_root       => $webroot,
        location       => '~ \.php$',
        fastcgi_params => '/etc/nginx/fastcgi_params',
        fastcgi        => 'multisite',
        try_files      => ['$uri', '$uri/', '/index.php?$args'],
    }

    Package['nginx'] ->
    php::fpm::conf { 'multisite':
      listen       => '/var/run/php5-fpm-multisite.sock',
      user         => 'www-data',
      listen_owner => 'www-data',
      listen_group => 'www-data',
    }

    file_line {
        'DOMAIN_CURRENT_SITE':
            path => "${webroot}/wp-config.php",
            line => "define('DOMAIN_CURRENT_SITE', '${multisite_host}');",
            match => "define\\('DOMAIN_CURRENT_SITE',";
    }
}
