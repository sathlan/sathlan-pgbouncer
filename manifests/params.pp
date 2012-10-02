class pgbouncer::params {
  case $::operatingsystem {
    'debian': {
      $package      = 'pgbouncer',
      $service      = 'pgbouncer',
      $conf_dir     = '/etc/pgbouncer',
      $start        = '/etc/defaults/pgbouncer',
    }
    default: {
      fail("Unsupported OS: $::operatingsystem")
    }
  }
}
