# install motd
class awesome::motd {
  class { 'updatemotd':
  #   purge_directory => true,
  }
  updatemotd::script { 'important':
    content => '#!/bin/bash\n/usr/bin/landscape-sysinfo --exclude-sysinfo-plugins=LandscapeLink',
  }
  updatemotd::script { 'warning':
    content => '#!/bin/bash\necho "Its dangerous to go alone, take this!"\n',
  }
}
