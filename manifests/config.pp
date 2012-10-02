class pgbouncer::config {
  $config = $pgbouncer::start_path
  concat { $config:
    owner => root,
    group => root,
    mode  => 0644,
  }

  # install pgbouncer permissions
  file { '/etc/pgbouncer/userlist.txt':
    content => template('pgbouncer/userlist.txt.erb'),
    owner   => $pgbouncer::user,
    group   => $pgbouncer::group,
    mode    => '0640',
  }
  
  concat::fragment { "${config}-header":
    target  => $config,
    content => '# MANAGED BY PUPPET',
    order   => 01,
  }
}
