class letsencrypt::renew {
    exec { 'letsencrypt renew':
        command     => "${letsencrypt::config_root}/letsencrypt.sh -c",
        refreshonly => true,
    } ~>
    exec { 'nginx restart':
        command     => '/usr/sbin/invoke-rc.d nginx reload',
        refreshonly => true,
    }
}
