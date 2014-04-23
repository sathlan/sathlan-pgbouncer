class pgbouncer::package {
  file { '/etc/init.d/pgbouncer':
    ensure => present,
    source => 'puppet:///modules/pgbouncer/init-pgbouncer.sh',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    notify => Package['pgbouncer'],
  }
  package { $pgbouncer::package:
    ensure => $pgbouncer::version,
  }
}
