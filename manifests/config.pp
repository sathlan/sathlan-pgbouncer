class pgbouncer::config {
  $config = "${pgbouncer::start}"
  concat { "$config":
    owner => root,
    group => root,
    mode  => 0644,
  }

  concat::fragment { "${config}-header":
    target  => "$config",
    content => "# MANAGED BY PUPPET",
    order   => 01,
  }
}
