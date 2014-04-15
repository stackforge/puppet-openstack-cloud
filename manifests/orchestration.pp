#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::orchestration
#
# Orchestration common node
#
# === Parameters:
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from internal network
#   Default value in params
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Default value in params
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_keystone_admin_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_heat_public_host*]
#   (optional) Public Hostname or IP to connect to Heat API
#   Default value in params
#
# [*ks_heat_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Default value in params
#
# [*heat_db_host*]
#   (optional) Hostname or IP address to connect to heat database
#   Default value in params
#
# [*heat_db_user*]
#   (optional) Username to connect to heat database
#   Default value in params
#
# [*heat_db_password*]
#   (optional) Password to connect to heat database
#   Default value in params
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Default value in params
#
# [*rabbit_password*]
#   (optional) Password to connect to heat queues.
#   Default value in params
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Default value in params
#
# [*debug*]
#   (optional) Set log output to debug output
#   Default value in params
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults value in params
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults value in params
#
class cloud::orchestration(
  $ks_keystone_internal_host  = $os_params::ks_keystone_internal_host,
  $ks_keystone_internal_port  = $os_params::ks_keystone_internal_port,
  $ks_keystone_internal_proto = $os_params::ks_keystone_internal_proto,
  $ks_keystone_admin_host     = $os_params::ks_keystone_admin_host,
  $ks_keystone_admin_port     = $os_params::ks_keystone_admin_port,
  $ks_keystone_admin_proto    = $os_params::ks_keystone_admin_proto,
  $ks_heat_public_host        = $os_params::ks_heat_public_host,
  $ks_heat_public_proto       = $os_params::ks_heat_public_proto,
  $ks_heat_password           = $os_params::ks_heat_password,
  $heat_db_host               = $os_params::heat_db_host,
  $heat_db_user               = $os_params::heat_db_user,
  $heat_db_password           = $os_params::heat_db_password,
  $rabbit_hosts               = $os_params::rabbit_hosts,
  $rabbit_password            = $os_params::rabbit_password,
  $verbose                    = $os_params::verbose,
  $debug                      = $os_params::debug,
  $use_syslog                 = $os_params::use_syslog,
  $log_facility               = $os_params::log_facility
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/heat'
  }

  $encoded_user     = uriescape($heat_db_user)
  $encoded_password = uriescape($heat_db_password)

  class { 'heat':
    keystone_host     => $ks_keystone_admin_host,
    keystone_port     => $ks_keystone_admin_port,
    keystone_protocol => $ks_keystone_admin_proto,
    keystone_password => $ks_heat_password,
    auth_uri          => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    sql_connection    => "mysql://${encoded_user}:${encoded_password}@${heat_db_host}/heat",
    rabbit_hosts      => $rabbit_hosts,
    rabbit_password   => $rabbit_password,
    rabbit_userid     => 'heat',
    verbose           => $verbose,
    debug             => $debug,
    log_facility      => $log_facility,
    use_syslog        => $use_syslog,
    log_dir           => $log_dir,
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Heat DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Gonéri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'heat_db_sync':
    command => 'heat-manage --config-file /etc/heat/heat.conf db_sync',
    path    => '/usr/bin',
    user    => 'heat',
    unless  => "/usr/bin/mysql heat -h ${heat_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
