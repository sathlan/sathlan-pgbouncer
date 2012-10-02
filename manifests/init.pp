class pgbouncer (
  $package    => $pgbouncer::params::package,
  $service    => $pgbouncer::params::service,
  $conf_dir   => $pgbouncer::params::conf_dir,
  $start_path => $pgbouncer::params::start,
  $enable     =>
  ) inherits pgbouncer::params {

  $args   = get_scope_args()
  $schema = {
    'type' => 'map',
    'mapping' => {
      'package' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+/$',
        'require' => 'yes',
      },
      'service' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+/$',
        'require' => 'yes',
      },
      'conf_dir' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+/$',
        'require' => 'yes',
      },
      'start_path' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+/$',
        'require' => 'yes',
      },
    }
  }

  kwalify($schema, $args)

  anchor { 'pgbouncer::begin': } ->
  class { 'pgbouncer::package': } ~>
  class { 'pgbouncer::config': }  ~>
  class { 'pgbouncer::service': } ~>
  anchor { 'pgbouncer::end': }
}
