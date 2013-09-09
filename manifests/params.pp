class pgbouncer::params {
  # default parameters.
  case $::osfamily {
    'Debian': {
      $package      = 'pgbouncer'
      $service      = 'pgbouncer'
      $conf_dir     = '/etc/pgbouncer'
      $start_path   = '/etc/default/pgbouncer'
    }
    default: {
      fail("Unsupported OS family: ${::osfamily}")
    }
  }
  $auth_path        = "${conf_dir}/userlist.txt"
  $enable           = true
  $ensure           = running
  $user             = 'postgres'
  $group            = 'postgres'
  $version          = installed
  $db_users         = {}
  # default configurations.
  $databases = {
    '*' => 'host=127.0.0.1 port=5432'
  }

  $pgbouncer = {
    'logfile'                   => '/var/log/postgresql/pgbouncer.log',
    'pidfile'                   => '/var/run/postgresql/pgbouncer.pid',
    'listen_addr'               => '*',
    'listen_port'               => '6432',
    'unix_socket_dir'           => '/var/run/postgresql',
    'auth_type'                 => 'trust',
    'auth_file'                 => $auth_path,
    'admin_users'               => 'postgres',
    'stats_users'               => 'postgres',
    'pool_mode'                 => 'transaction',
    'server_reset_query'        => 'DISCARD ALL',
    'ignore_startup_parameters' => 'extra_float_digits application_name',
    'server_check_query'        => 'select 1',
    'server_check_delay'        => '10',
    'max_client_conn'           => '250',
    'default_pool_size'         => '30',
    'reserve_pool_size'         => '2',
    'reserve_pool_timeout'      => '2',
    'log_connections'           => '1',
    'log_disconnections'        => '1',
    'log_pooler_errors'         => '1',
    'server_idle_timeout'       => '60',
  }
}
