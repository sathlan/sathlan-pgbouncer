# == Class: pgbouncer
#
# Install pgbouncer.  See pgbouncer::instance for configuration of the daemon(s)
#
# === Parameters
#
# [*package*]
#   name of the package
#
# [*service*]
#   name of the service
#
# [*conf_dir*]
#   name of the configuration directory
#
# [*start_path*]
#   name of the enabling service file
#
# [*enable*]
#   enable the service at boot ?
#
# [*ensure*]
#   ensure service is running ?
#
# === Variables
#
# This module requires no variable to be defined.
#
# === Examples
#
#  class { 'pgbouncer': }
#
# === Authors
#
# Author Name <sathlan@unix4.me>
#
# === Copyright
#
# Copyright 2012 Sofer Athlan, unless otherwise noted.
#
class pgbouncer (
  $package    = $pgbouncer::params::package,
  $service    = $pgbouncer::params::service,
  $conf_dir   = $pgbouncer::params::conf_dir,
  $start_path = $pgbouncer::params::start_path,
  $enable     = $pgbouncer::params::enable,
  $ensure     = $pgbouncer::params::ensure,
  $user       = $pgbouncer::params::user,
  $group      = $pgbouncer::params::group,
  $version    = $pgbouncer::params::version,
  $db_users   = $pgbouncer::params::db_users,
  ) inherits pgbouncer::params {

  $args   = get_scope_args()
  $schema = {
    'type' => 'map',
    'mapping' => {
      'package' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
        'required' => true,
      },
      'service' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
        'required' => true,
      },
      'conf_dir' => {
        'type'    => 'str',
        'pattern' => '/^[-\/.\w_\d]+$/',
        'required' => true,
      },
      'start_path' => {
        'type'    => 'str',
        'pattern' => '/^[-\/.\w_\d]+$/',
        'required' => true,
      },
      'enable' => {
        'type' => any,
        'enum' => [true, false, 'manual'],
        'required' => true,
      },
      'ensure' => {
        'type' => any,
        'enum' => [true, false, running, stopped],
        'required' => true,
      },
      'user' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
        'required' => true,
      },
      'group' => {
        'type'    => 'str',
        'pattern' => '/^[-.\w_\d]+$/',
        'required' => true,
      },
      'version' => {
        'type'    => 'str',
        'pattern' => '/^[+-~.\w_\d]+$/',
        'required' => true,
      },
      'db_users' => {
        'type' => 'map',
        'mapping' => {
          '=' => {
            'type' => 'any'
          },
        },
      },
    }
  }

  kwalify($schema, $args)

  anchor { 'pgbouncer::begin'   : } ->
  class  { 'pgbouncer::package' : } ~>
  class  { 'pgbouncer::config'  : } ~>
  class  { 'pgbouncer::service' : } ~>
  anchor { 'pgbouncer::end'     : }
}
