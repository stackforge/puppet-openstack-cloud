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
# This class is deprecated for cloud::image::api and cloud::image::registry
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

  warning('This class is deprecated. You should use cloud::image::api and cloud::image::registry.')

  # Maintain backward compatibility with H.1.2.0
  class { 'cloud::image::api':
    glance_db_host                   => $glance_db_host,
    glance_db_user                   => $glance_db_user,
    glance_db_password               => $glance_db_password,
    openstack_vip                    => $openstack_vip,
    ks_glance_registry_internal_port => $ks_glance_registry_internal_port,
    verbose                          => $verbose,
    debug                            => $debug,
    ks_keystone_internal_host        => $ks_keystone_internal_host,
    ks_glance_password               => $ks_glance_password,
    log_facility                     => $log_facility,
    api_eth                          => $api_eth,
    ks_glance_api_internal_port      => $ks_glance_api_internal_port,
    use_syslog                       => $use_syslog,
    glance_rbd_pool                  => $glance_rbd_pool,
    glance_rbd_user                  => $glance_rbd_user,
  }
  class { 'cloud::image::registry':
    glance_db_host                   => $glance_db_host,
    glance_db_user                   => $glance_db_user,
    glance_db_password               => $glance_db_password,
    verbose                          => $verbose,
    debug                            => $debug,
    ks_keystone_internal_host        => $ks_keystone_internal_host,
    ks_glance_password               => $ks_glance_password,
    api_eth                          => $api_eth,
    ks_glance_registry_internal_port => $ks_glance_registry_internal_port,
    use_syslog                       => $use_syslog,
    log_facility                     => $log_facility,
  }

}
