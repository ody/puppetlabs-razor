class razor::torquebox::install(
  $pkg_url      = $razor::torquebox::pkg_url,
  $unpack_root  = $razor::torquebox::unpack_root,
  $install_dest = $razor::torquebox::install_dest,
  $user         = $razor::torquebox::user,
) inherits razor::torquebox {

  # Put the archive into place, if needed.
  exec { "install torquebox binary distribution to ${install_dest}":
    provider => shell,
    command  => template('razor/install-zip.sh.erb'),
    path     => '/bin:/usr/bin:/usr/local/bin:/opt/bin',
    creates  => "${install_dest}/jruby/bin/torquebox",
    require  => [ Package['curl'], Package['unzip'] ]
  }

  user { $user:
    ensure   => present,
    system   => true,           # system -- daemon -- user, please
    password => '*',            # no password logins, please
    home     => $install_dest,
    shell    => '/bin/bash',    # if it comes up, let's be common
    comment  => 'razor-server daemon user',
  }
}
