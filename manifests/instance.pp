# == Class: pgbouncer::instance
#
# Install and configure a pgbouncer.
#
# === Parameters
#
# [*index*]
#   the number in the configuration, starting at 0.
#
# [*databases*]
#   hash of databases with string definition
#
# [*pgbouncer*]
#   hash of options
#
# === Examples
#
#  pgbouncer::instance { 'transactions':
#    databases => {
#      '*' => 'host=127.0.0.1 port=5432'
#    },
#    # every other parameters will take $pgbouncer::params::pgbouncer values as default
#    pgbouncer => {
#      'listen_port'       => '6432',
#      'pool_mode'         => 'transaction',
#      'max_client_conn'   => 500,
#      'default_pool_size' => 80,
#    }
#  }
#
# === Authors
#
# Author Name <sathlan@unix4.net>
#
# === Copyright
#
# Copyright 2012 Athlan-Guyot Sofer 
#
define pgbouncer::instance (
  $index,
  $databases  = {},
  $pgbouncer  = {},
  $basedir    = '',
  $options    = '',
  $prefix_cmd = '',
  $order      = 50,
  ) {
  $args   = get_scope_args()
  $schema = {
    'type' => 'map',
    'mapping' => {
      'databases' => {
        'type' => 'map',
        'mapping' => {
          '=' => {
            'type' => 'any'
          }
        },
      },
      'pgbouncer' => {
        'type' => 'map',
        'mapping' => {
          '=' => {
            'type' => 'any'
          }
        },
      },
      'index' => {
        'type'    => 'str',
        'pattern' => '/^[0-9]+$/'
      },
      'user' => {
        'type'    => 'str',
        'pattern' => '/^\w[-.\w_\d]*$/',
      },
      'basedir' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]*$/',
      },
      'options'    => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]*$/',
      },
      'prefix_cmd' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]*$/',
      },
      'order' => {
        'type'    => 'str',
        'pattern' => '/^[0-9]+$/'
      }
    }
  }

  kwalify($schema, $args)

  # get default values
  $databases_conf = merge($databases, $pgbouncer::params::databases)
  $pgbouncer_conf = merge($pgbouncer, $pgbouncer::params::pgbouncer)

  # install default startup
  concat::fragment { "${name}-instance":
    target  => $pgbouncer::start,
    content => template('pgbouncer/instance.erb'),
    order   => $order + $index,
    require => Class['pgbouncer::package'],
    notify  => Class['pgbouncer::service'],
  }

  # install configuration
  file { "${pgbouncer::conf_dir}/${name}.ini":
    ensure  => present,
    owner   => $pgbouncer::user,
    group   => $pgbouncer::group,
    mode    => '0640',
    content => template('pgbouncer/pgbouncer.ini.erb'),
    require => [ Concat::Fragment["${name}-instance"], Class['pgbouncer::package'] ],
    notify  => Class['pgbouncer::service'],
  }
}
