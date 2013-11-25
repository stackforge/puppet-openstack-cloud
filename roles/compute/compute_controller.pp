#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Compute controller node
#

class os_computr_controller(
  $local_ip = $ipaddress_eth1,
){

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor',
  ]:
    enabled => true,
  }

  class spicehtml5proxy(
    $enabled        = true,
    $host           = '0.0.0.0',
    $port           = '6082',
    $ensure_package = 'present'
  ) {
    nova_config {
      'DEFAULT/spicehtml5proxy_host': value => $host;
      'DEFAULT/spicehtml5proxy_port': value => $port;
    }
    nova::generic_service { 'spicehtml5proxy':
      enabled        => $true,
      package_name   => 'nova-consoleproxy',
      service_name   => 'nova-spicehtml5proxy',
      ensure_package => $ensure_package,
    }
  }

  class { 'nova::api':
    enabled                              => true,
    auth_host                            => $os_params::ks_keystone_internal_host,
    admin_password                       => $os_params::ks_nova_password,
    quantum_metadata_proxy_shared_secret => $os_params::quantum_metadata_proxy_shared_secret,
  }

}
