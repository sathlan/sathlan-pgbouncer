class pgbouncer::service ($ensure = running) {
  service { 'pgbouncer':
    ensure  => $ensure,
    require => Package['pgbouncer'],
  }
}
