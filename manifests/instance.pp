define pgbouncer::instance (
  $index,
  $user = 'postgres',
  $basedir = '',
  $options = '',
  $prefix_cmd = '',
  ) {
  $args   = get_scope_args()
  $schema = {
    'type' => 'map',
    'mapping' => {
      'index' => {
        'type'    => 'int',
      },
      'user' => {
        'type'    => 'str',
        'pattern' => '/^\w[-.\w_\d]+$/',
      },
      'basedir' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]*$/',
      },
      'options'    => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
      },
      'prefix_cmd' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
      }
    }
  }

  kwalify($schema, $args)

  concat::fragment { "${name}-instance":
    target  => "${pgbouncer::start}",
    content => template('pgbouncer/instance.erb'),
    order   => $order + $index,
    require => Class['pgbouncer::package'],
    notify  => Class['pgbouncer::service'],
}
