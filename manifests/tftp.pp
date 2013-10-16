class razor::tftp($razor_server) {
  include ::tftp
  class { 'razor::tftp::files': razor_server=> $razor_server }
  Class['::tftp'] -> Class['razor::tftp::files']
}
