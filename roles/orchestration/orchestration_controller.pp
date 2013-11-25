#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Sebastien Badia <sebastien.badia@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
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
# Orchestration controller node
#
class os_orchestration_controller {
  class { 'heat':
    keystone_host     => $os_params::ks_heat_public_host,
    keystone_port     => $os_params::ks_heat_public_port,
    keystone_protocol => $os_params::ks_heat_public_proto,
    keystone_password => $os_params::ks_heat_password,
  }

  class { 'heat::api': }

  class { 'heat':
    keystone_host     => $os_params::ks_keystone_public_host,
    keystone_password => $os_params::ks_heat_password,
    auth_uri          => "${os_params::ks_keystone_public_proto}://${os_params::ks_keystone_public_host}:35357/v2.0",
    rabbit_hosts      => $os_params::rabbit_hosts,
    rabbit_password   => $os_params::rabbit_password,
  }

  class { 'heat::db':
    sql_connection => "mysql://${os_params::heat_db_user}:${os_params::heat_db_password}@${os_params::heat_db_host}/heat",
  }

  class { 'heat::engine':
    heat_metadata_server_url      => "${os_params::ks_heat_public_proto}://${os_params::ks_keystone_public_host}:8000",
    heat_waitcondition_server_url => "${os_params::ks_heat_public_proto}://${os_params::ks_keystone_public_host}:8000/v1/waitcondition",
    heat_watch_server_url         => "${os_params::ks_heat_public_proto}://${os_params::ks_keystone_public_host}:8003",
  }

}
