class razor::server(
  $user_pw,
  $pkg_url          = 'http://links.puppetlabs.com/razor-server-latest.zip',
  $install_dest     = '/opt/razor',
  $log_level        = 'debug',
  $checkin_interval = 15,
  $repo_dir         = '/var/lib/razor/repo-store',
  $app_env          = 'production',
) {


  # Install our own TorqueBox bundle, quietly.  This isn't intended to be
  # shared with anyone else, so we don't use a standard module.

  # Loading Class['razor::torquebox'] first so that default variables initialize and
  # class needs data from it.  If you need to set custom values just declare
  # Class['razor::torquebox'] in a higher namespace, e.g. a role/profile or ENC.
  include razor::torquebox

  # Have to be separate classes since one part of torquebox setup happens before razor
  # and the rest after.
  include razor::torquebox::install
  include razor::torquebox::service

  Class['razor::torquebox::install'] -> Class['razor::server'] ~> Class['razor::torquebox::service']

  # Put the archive into place, if needed.
  exec { "install razor binary distribution to ${install_dest}":
    provider => shell,
    command  => template('razor/install-zip.sh.erb'),
    path     => '/bin:/usr/bin:/usr/local/bin:/opt/bin',
    creates  => "${install_dest}/bin/razor-admin",
    require  => [ Package['curl'], Package['unzip'] ],
    notify   => Exec['deploy razor to torquebox'],
  }

  exec { 'deploy razor if it was undeployed':
    provider => shell,
    unless   => "test -f ${razor::torquebox::install_dest}/jboss/standalone/deployments/razor-knob.yml",
    # This is actually "notify if the file does not exist" :)
    command  => ':',
    notify   => Exec['deploy razor to torquebox'],
    require  => Exec["install razor binary distribution to ${install_dest}"],
  }

  # deploy razor, if required.
  exec { 'deploy razor to torquebox':
    command     => "${razor::torquebox::install_dest}/jruby/bin/torquebox deploy --env production",
    cwd         => $install_dest,
    environment => [
      "TORQUEBOX_HOME=${razor::torquebox::install_dest}",
      "JBOSS_HOME=${razor::torquebox::install_dest}/jboss",
      "JRUBY_HOME=${razor::torquebox::install_dest}/jruby"
    ],
    path        => "${razor::torquebox::install_dest}/jruby/bin:/bin:/usr/bin:/usr/local/bin",
    require     => Exec["install razor binary distribution to ${install_dest}"],
    notify      => Exec['razor db migration'],
    refreshonly => true,
  }

  file { "${install_dest}/bin/razor-binary-wrapper":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('razor/razor-binary-wrapper.erb'),
    require => Exec["install razor binary distribution to ${install_dest}"],
  }

  file { '/usr/local/bin/razor-admin':
    ensure => link,
    target => "${install_dest}/bin/razor-binary-wrapper",
  }

  # Work around what seems very much like a bug in the package...
  file { "${install_dest}/bin/razor-admin":
    mode    => '0755',
    require => Exec["install razor binary distribution to ${install_dest}"],
  }

  $supporting_dirs = [ '/var/lib/razor', $repo_dir, "${install_dest}/log" ]

  file { $supporting_dirs:
    ensure  => directory,
    owner   => $razor::torquebox::user,
    group   => $razor::torquebox::group,
    mode    => '0775',
    require => Exec["install razor binary distribution to ${install_dest}"]
  }

  file { "${install_dest}/log/production.log":
    ensure  => file,
    owner   => $razor::torquebox::user,
    group   => $razor::torquebox::group,
    mode    => '0660',
    require => File[$supporting_dirs],
  }

  file { 'razor config.yaml':
    path    => "${install_dest}/config.yaml",
    content => template('razor/config.yaml.erb'),
    owner   => $razor::torquebox::user,
    group   => $razor::torquebox::group,
    mode    => '0660',
    require => Exec["install razor binary distribution to ${install_dest}"],
  }

  # Do database migration if we got notified by Class['razor::server::install']
  exec { 'razor db migration':
    command     => 'jruby bin/razor-admin -e production migrate-database',
    cwd         => $install_dest,
    environment => [
      "TORQUEBOX_HOME=${razor::torquebox::install_dest}",
      "JBOSS_HOME=${razor::torquebox::install_dest}/jboss",
      "JRUBY_HOME=${razor::torquebox::install_dest}/jruby"
    ],
    path        => "${razor::torquebox::install_dest}/jruby/bin:/bin:/usr/bin:/usr/local/bin",
    require     => File[[ $supporting_dirs, 'razor config.yaml']],
    refreshonly => true,
  }
}
