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
# == Class: cloud::compute
#
# Common class for compute nodes
#
# === Parameters:
#
# [*nova_db_host*]
#   (optional) Hostname or IP address to connect to nova database
#   Default value in params
#
# [*nova_db_user*]
#   (optional) Username to connect to nova database
#   Default value in params
#
# [*nova_db_password*]
#   (optional) Password to connect to nova database
#   Default value in params
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Default value in params
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Default value in params
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Default value in params
#
# [*glance_api_port*]
#   (optional) TCP port to connect to Glance API
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
# [*memcache_servers*]
#   (optionnal) Memcached servers used by Keystone. Should be an array.
#   Default value in params
#

class cloud::compute(
  $nova_db_host            = $os_params::nova_db_host,
  $nova_db_user            = $os_params::nova_db_user,
  $nova_db_password        = $os_params::nova_db_password,
  $rabbit_hosts            = $os_params::rabbit_hosts,
  $rabbit_password         = $os_params::rabbit_password,
  $ks_glance_internal_host = $os_params::ks_glance_internal_host,
  $glance_api_port         = $os_params::ks_glance_api_internal_port,
  $verbose                 = $os_params::verbose,
  $debug                   = $os_params::debug,
  $use_syslog              = $os_params::use_syslog,
  $log_facility            = $os_params::log_facility,
  $neutron_endpoint        = $os_params::ks_neutron_admin_host,
  $neutron_protocol        = $os_params::ks_neutron_admin_proto,
  $neutron_password        = $os_params::ks_neutron_password,
  $neutron_region_name     = $os_params::region,
  $memcache_servers        = $os_params::memcache_servers,
  $availability_zone       = $os_params::region
) {

  if !defined(Resource['nova_config']) {
    resources { 'nova_config':
      purge => true;
    }
  }

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/nova'
  }

  $encoded_user     = uriescape($nova_db_user)
  $encoded_password = uriescape($nova_db_password)

  class { 'nova':
    database_connection => "mysql://${encoded_user}:${encoded_password}@${nova_db_host}/nova?charset=utf8",
    rabbit_userid       => 'nova',
    rabbit_hosts        => $rabbit_hosts,
    rabbit_password     => $rabbit_password,
    glance_api_servers  => "http://${ks_glance_internal_host}:${glance_api_port}",
    memcached_servers   => $memcache_servers,
    verbose             => $verbose,
    debug               => $debug,
    log_dir             => $log_dir,
    log_facility        => $log_facility,
    use_syslog          => $use_syslog,
  }

  class { 'nova::network::neutron':
      neutron_admin_password => $neutron_password,
      neutron_admin_auth_url => "${neutron_protocol}://${neutron_endpoint}:35357/v2.0",
      neutron_url            => "${neutron_protocol}://${neutron_endpoint}:9696",
      neutron_region_name    => $neutron_region_name
  }

  nova_config {
    'DEFAULT/resume_guests_state_on_host_boot': value => true;
    'DEFAULT/default_availability_zone':        value => $availability_zone;
    'DEFAULT/servicegroup_driver':              value => 'mc';
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Nova DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Gonéri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'nova_db_sync':
    command => 'nova-manage db sync',
    user    => 'nova',
    path    => '/usr/bin',
    unless  => "/usr/bin/mysql nova -h ${nova_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
