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

class os_compute_controller(
  $ks_keystone_internal_host            = $os_params::ks_keystone_internal_host,
  $ks_nova_password                     = $os_params::ks_nova_password,
  $neutron_metadata_proxy_shared_secret = $os_params::neutron_metadata_proxy_shared_secret,
){

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor',
    'nova::spicehtml5proxy',
  ]:
    enabled => true,
  }

  class { 'nova::api':
    enabled                              => true,
    auth_host                            => $ks_keystone_internal_host,
    admin_password                       => $ks_nova_password,
    neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_shared_secret,
  }

}
