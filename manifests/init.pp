# Class: razor
#
# Parameters:
#
# [*servername*]: the DNS name or IP address of the Razor server (default: `$fqdn`)
# [*libarchive*]: the name of the libarchive package.  (default: autodetect)
# [*tftp*]: should TFTP services be installed and configured on this machine? (default: true)
#
# Actions:
#
#   Installs and runs the razor-server, along with all dependencies.
#
# Usage:
#
#   include razor
#
class razor (
  $servername = $fqdn,
  $libarchive = undef,
  $tftp       = true,
) {
  # Ensure libarchive is installed -- the users requested custom version, or
  # our own guesswork as to what the version is on this platform.
  if $libarchive {
    ensure_packages([$libarchive])
  } else {
    include razor::libarchive
  }

  ensure_packages([ 'unzip', 'curl' ])

  # Install a JVM, since we need one
  include java
  Class['java'] -> Class['razor']

  # Setup the razor-server application which will also install a copy of
  # torquebox specificly for use by razor.
  include razor::server

  if $tftp {
    class { 'razor::tftp': razor_server => $servername }
  }
}
