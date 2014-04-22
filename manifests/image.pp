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
#   Defaults to '127.0.0.1'
#
# [*glance_db_user*]
#   (optional) Username to connect to glance database
#   Defaults to 'glance'
#
# [*glance_db_password*]
#   (optional) Password to connect to glance database
#   Defaults to 'glancepassword'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from internal network
#   Defaults to '9292'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance Registry from internal network
#   Defaults to '9191'
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to '127.0.0.1'
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*api_eth*]
#   (optional) Which interface we bind the Glance API server.
#   Defaults to '127.0.0.1'
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#

class cloud::image(
  $glance_db_host                   = '127.0.0.1',
  $glance_db_user                   = 'glance',
  $glance_db_password               = 'glancepassword',
  $ks_keystone_internal_host        = '127.0.0.1',
  $ks_glance_internal_host          = '127.0.0.1',
  $ks_glance_api_internal_port      = 9292,
  $ks_glance_registry_internal_port = 9191,
  $ks_glance_password               = 'glancepassword',
  $rabbit_password                  = 'rabbitpassword',
  $rabbit_host                      = '127.0.0.1',
  $api_eth                          = '127.0.0.1',
  $openstack_vip                    = undef,
  $glance_rbd_pool                  = 'images',
  $glance_rbd_user                  = 'glance',
  $verbose                          = true,
  $debug                            = true,
  $log_facility                     = 'LOG_LOCAL0',
  $use_syslog                       = true
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
  # Follow-up: https://github.com/enovance/puppet-openstack-cloud/issues/160
  #
  # class { 'glance::notify::rabbitmq':
  #   rabbit_password => $rabbit_password,
  #   rabbit_userid   => 'glance',
  #   rabbit_host     => $rabbit_host,
  # }
  glance_api_config {
    # TODO(EmilienM) Will be deprecated in Icehouse for notification_driver.
    'DEFAULT/notifier_strategy': value => 'noop';
  }

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
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'glance_db_sync':
    command => 'glance-manage db_sync',
    user    => 'glance',
    path    => '/usr/bin',
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
