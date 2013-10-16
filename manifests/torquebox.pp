class razor::torquebox(
  $pkg_url      = 'http://torquebox.org/release/org/torquebox/torquebox-dist/3.0.1/torquebox-dist-3.0.1-bin.zip',
  $unpack_root  = 'torquebox-3.0.1',
  $install_dest = '/opt/razor-torquebox',
  $user         = 'razor-server',
  $group        = 'razor-server',
) {

  # Nothing here on purpose.  The base torquebox class is being used as a unified place
  # to put data that is used be the install and service subclass.  This class is
  # inherited by its subclass so that data is passed properly.
}
