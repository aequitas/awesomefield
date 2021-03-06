class awesome::multisite (
    $db='multisite',
    $db_user='multisite',
    $db_password=undef,
    $db_backup_user='backup',
    $db_backup_password=undef,
    $db_backup_dir='/var/backups/mysql/',
    $db_backup='/var/backups/multisite.sql',
    $multisite_host='awesomnia.awesomeretro.org',
    $multisite_subdomains=[],
    $php_value={},
    $php_flag={},
){
    $webroot = '/var/www/multisite/html/'

    ensure_packages(['php5-mysql', 'php5-curl', 'php5-gd', 'php5-mcrypt', 'php5-xcache'])

    # create wordpress DB
    mysql::db { $db:
        user     => $db_user,
        password => $db_password,
        host     => 'localhost',
        grant    => ['SELECT', 'UPDATE', 'INSERT', 'DELETE', 'CREATE', 'ALTER'],
        sql      => $db_backup,
    }

    class { 'mysql::server::backup':
        backupuser     => $db_backup_user,
        backuppassword => $db_backup_password,
        backupdir      => $db_backup_dir,
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

    Package['nginx'] ->
    php::fpm::conf { 'multisite':
        listen               => '/var/run/php5-fpm-multisite.sock',
        user                 => 'www-data',
        listen_owner         => 'www-data',
        listen_group         => 'www-data',
        pm_max_children      => 3,
        pm_start_servers     => 2,
        pm_min_spare_servers => 1,
        pm_max_spare_servers => 3,
        php_value            => $php_value,
        php_flag             => $php_flag,
    }
    logrotate::rule { 'php-fpm-multisite-errors':
        path         => '/var/log/php-fpm/multisite-error.log',
        rotate       => 7,
        rotate_every => 'day',
        compress     => true,
        su           => true,
        su_owner     => 'www-data',
        su_group     => 'www-data',
    }

    file_line {
        'DOMAIN_CURRENT_SITE':
            path => "${webroot}/wp-config.php",
            line => "define('DOMAIN_CURRENT_SITE', '${multisite_host}');",
            match => "define\\('DOMAIN_CURRENT_SITE',";
    }

    nginx::resource::upstream { 'multisite':
        members => [
            'unix:/var/run/php5-fpm-multisite.sock',
        ],
    }

    awesome::vhosts::multisite {'awesomnia.awesomeretro.org':
        webroot             => $webroot,
        server_name         => '_',
        listen_options      => 'default_server',
        ipv6_listen_options => 'default_server',
        subdomains          => $multisite_subdomains,
    }

    create_resources(vhosts::multisite, hiera_hash('vhosts::multisite'), {})
}
