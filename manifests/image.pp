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
# == Class: cloud::image
#
# Install Image Server (Glance)
#
# === Parameters:
#
# [*glance_db_host*]
#   (optional) Hostname or IP address to connect to glance database
#   Default value in params
#
# [*glance_db_user*]
#   (optional) Username to connect to glance database
#   Default value in params
#
# [*glance_db_password*]
#   (optional) Password to connect to glance database
#   Default value in params
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from internal network
#   Default value in params
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance Registry from internal network
#   Default value in params
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
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
# [*api_eth*]
#   (optional) Which interface we bind the Glance API server.
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
class cloud::image(
  $glance_db_host                   = $os_params::glance_db_host,
  $glance_db_user                   = $os_params::glance_db_user,
  $glance_db_password               = $os_params::glance_db_password,
  $ks_keystone_internal_host        = $os_params::ks_keystone_internal_host,
  $ks_glance_internal_host          = $os_params::ks_glance_internal_host,
  $ks_glance_api_internal_port      = $os_params::ks_glance_api_internal_port,
  $ks_glance_registry_internal_port = $os_params::ks_glance_registry_internal_port,
  $ks_glance_password               = $os_params::ks_glance_password,
  $rabbit_password                  = $os_params::rabbit_password,
  $rabbit_host                      = $os_params::rabbit_host,
  $api_eth                          = $os_params::api_eth,
  $openstack_vip                    = $os_params::vip_public_ip,
  $glance_rbd_pool                  = $os_params::glance_rbd_pool,
  $glance_rbd_user                  = $os_params::glance_rbd_user,
  $verbose                          = $os_params::verbose,
  $debug                            = $os_params::debug,
  $log_facility                     = $os_params::log_facility,
  $use_syslog                       = $os_params::use_syslog
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir           = false
    $log_file_api      = false
    $log_file_registry = false
  } else {
    $log_dir           = '/var/log/glance'
    $log_file_api      = '/var/log/glance/api.log'
    $log_file_registry = '/var/log/glance/registry.log'
  }

  $encoded_glance_user     = uriescape($glance_db_user)
  $encoded_glance_password = uriescape($glance_db_password)

  class { 'glance::api':
    sql_connection        => "mysql://${encoded_glance_user}:${encoded_glance_password}@${glance_db_host}/glance",
    registry_host         => $openstack_vip,
    registry_port         => $ks_glance_registry_internal_port,
    verbose               => $verbose,
    debug                 => $debug,
    auth_host             => $ks_keystone_internal_host,
    keystone_password     => $ks_glance_password,
    keystone_tenant       => 'services',
    keystone_user         => 'glance',
    show_image_direct_url => true,
    log_dir               => $log_dir,
    log_file              => $log_file_api,
    log_facility          => $log_facility,
    bind_host             => $api_eth,
    bind_port             => $ks_glance_api_internal_port,
    use_syslog            => $use_syslog,
  }

  class { 'glance::registry':
    sql_connection    => "mysql://${encoded_glance_user}:${encoded_glance_password}@${glance_db_host}/glance",
    verbose           => $verbose,
    debug             => $debug,
    auth_host         => $ks_keystone_internal_host,
    keystone_password => $ks_glance_password,
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    bind_host         => $api_eth,
    log_dir           => $log_dir,
    log_file          => $log_file_registry,
    bind_port         => $ks_glance_registry_internal_port,
    use_syslog        => $use_syslog,
    log_facility      => $log_facility,
  }

  # TODO(EmilienM) Disabled for now
  # Follow-up: https://github.com/enovance/puppet-cloud/issues/160
  #
  # class { 'glance::notify::rabbitmq':
  #   rabbit_password => $rabbit_password,
  #   rabbit_userid   => 'glance',
  #   rabbit_host     => $rabbit_host,
  # }

  class { 'glance::backend::rbd':
    rbd_store_user => $glance_rbd_user,
    rbd_store_pool => $glance_rbd_pool
  }

  Ceph::Key <<| title == $glance_rbd_user |>>
  file { '/etc/ceph/ceph.client.glance.keyring':
    owner   => 'glance',
    group   => 'glance',
    mode    => '0400',
    require => Ceph::Key[$glance_rbd_user]
  }
  Concat::Fragment <<| title == 'ceph-client-os' |>>

  class { 'glance::cache::cleaner': }
  class { 'glance::cache::pruner': }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Glance DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Gonéri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-cloud/issues/156
  exec {'glance_db_sync':
    command => '/usr/bin/glance-manage db_sync',
    unless  => "/usr/bin/mysql glance -h ${glance_db_host} -u ${encoded_glance_user} -p${encoded_glance_password} -e \"show tables\" | /bin/grep Tables"
  }

  # TODO(EmilienM) For later, I'll also add internal network support in HAproxy for all OpenStack API, to optimize North / South network traffic
  @@haproxy::balancermember{"${::fqdn}-glance_api":
    listening_service => 'glance_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_api_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

@@haproxy::balancermember{"${::fqdn}-glance_registry":
    listening_service => 'glance_registry_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_registry_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
