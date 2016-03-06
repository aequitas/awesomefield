define awesome::user (
    $ensure = absent,
    $key = undef,
    $type = 'rsa',
    $sudo = false,
    $shell = '/bin/bash',
){
    if $sudo {
        $sudo_ensure = present
        $groups = ['sudo']
    } else {
        $sudo_ensure = absent
        $groups = []
    }

    user { $name:
        ensure     => $ensure,
        managehome => true,
        groups     => $groups,
        shell      => $shell,
    } ->
    ssh_authorized_key { $name:
        ensure => $ensure,
        user   => $name,
        type   => $type,
        key    => $key,
    }

    ssh_authorized_key { "${name}-sudo":
        ensure => $sudo_ensure,
        target => "/etc/sudo_ssh_authorized_keys/${name}",
        type   => $type,
        key    => $key,
        user   => 'root',
    }
}
