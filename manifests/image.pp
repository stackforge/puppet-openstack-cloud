#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
# == Class: privatecloud::image
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
# [*ks_glance_public_port*]
#   (optional) TCP port to connect to Glance API from internal network
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
# [*local_ip*]
#   (optional) Which interface we bind the Keystone server. Should be depracted soon (see below).
#   Default to $::ipaddress_eth0
#

class privatecloud::image(
  $glance_db_host              = $os_params::glance_db_host,
  $glance_db_user              = $os_params::glance_db_user,
  $glance_db_password          = $os_params::glance_db_password,
  $ks_keystone_internal_host   = $os_params::ks_keystone_internal_host,
  $ks_glance_public_port       = $os_params::ks_glance_public_port,
  $ks_glance_password          = $os_params::ks_glance_password,
  $rabbit_password             = $os_params::rabbit_password,
  $rabbit_host                 = $os_params::rabbit_hosts[0],
  # TODO(EmilienM) Rename local_ip to a more general param, like "api_eth"
  $local_ip                    = $::ipaddress_eth0,
) {

  $encoded_glance_user     = uriescape($glance_db_user)
  $encoded_glance_password = uriescape($glance_db_password)

  class { ['glance::api', 'glance::registry']:
    sql_connection            => "mysql://${encoded_glance_user}:${encoded_glance_password}@${glance_db_host}/glance",
    verbose                   => false,
    debug                     => false,
    auth_host                 => $ks_keystone_internal_host,
    keystone_password         => $ks_glance_password,
    keystone_tenant           => 'services',
    keystone_user             => 'glance',
    log_facility              => 'LOG_LOCAL0',
    use_syslog                => true
  }

  class { 'glance::notify::rabbitmq':
    rabbit_password => $rabbit_password,
    rabbit_userid   => 'glance',
    rabbit_host     => $rabbit_host,
  }

  # TODO(EmilienM) We should migrate the backend to Ceph (WIP). For now, I let Swift.
  class { 'glance::backend::swift':
    swift_store_user         => 'services:glance',
    swift_store_key          => $ks_keystone_glance_password,
    swift_store_auth_address => $ks_keystone_internal_host,
  }

  class { 'glance::cache::cleaner': }
  class { 'glance::cache::pruner': }

  # TODO(EmilienM) For later, I'll also add internal network support in HAproxy for all OpenStack API, to optimize North / South network traffic
  @@haproxy::balancermember{"${::fqdn}-public_api":
    listening_service => 'glance_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $ks_glance_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
