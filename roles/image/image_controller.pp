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
# Image controller
#

class os_image_controller(
  $glance_db_user              = $os_params::glance_db_user,
  $glance_db_password          = $os_params::glance_db_password,
  $ks_keystone_internal_host   = $os_params::ks_keystone_internal_host,
  $ks_glance_internal_port     = $os_params::ks_glance_internal_port,
  $ks_keystone_glance_password = $os_params::ks_glance_password,
  $rabbit_password             = $os_params::rabbit_password,
  $rabbit_host                 = $os_params::rabbit_password[0]
) {
  $encoded_glance_user     = uriescape($glance_db_user)
  $encoded_glance_password = uriescape($glance_db_password)

  class { ['glance::api', 'glance::registry']:
    sql_connection            => "mysql://${encoded_glance_user}:${encoded_glance_password}@${os_params::glance_db_host}/glance",
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

  class { 'glance::backend::swift':
    swift_store_user         => 'services:glance',
    swift_store_key          => $ks_keystone_glance_password,
    swift_store_auth_address => $ks_keystone_internal_host_
  }

  @@haproxy::balancermember{"${fqdn}-glance_api":
    listening_service => "glance_api_cluster",
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $ks_glance_internal_port,
    options           => "check inter 2000 rise 2 fall 5"
  }

}
