class razor::client {

  package { 'razor-client':
    ensure   => present,
    provider => gem,
  }
}
