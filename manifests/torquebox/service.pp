class razor::torquebox::service(
  $install_dest = $razor::torquebox::install_dest,
  $user         = $razor::torquebox::user,
  $group        = $razor::torquebox::group,
) inherits razor::torquebox {

  # Install an init script for the Razor torquebox install
  file { '/etc/init.d/razor-server':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('razor/razor-server.init.erb'),
  }

  file { '/var/log/razor-server':
    ensure => directory,
    owner  => $user,
    group  => 'root',
    mode   => '0755',
  }

  file { '/opt/razor-torquebox/jboss/standalone':
    ensure   => directory,
    owner    => $user,
    group    => $group,
    recurse  => true,
    checksum => none,
    require  => Class['razor::torquebox::install'],
    before   => Service['razor-server'],
  }

  service { 'razor-server':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true
  }
}
