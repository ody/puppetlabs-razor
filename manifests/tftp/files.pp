class razor::tftp::files($razor_server = $fqdn) {

  ::tftp::file { 'undionly.kpxe': }
  ::tftp::file { 'ipxe.lkrn': }

  ::tftp::file { 'bootstrap.ipxe':
    content => template('razor/bootstrap.ipxe.erb')
  }
}
