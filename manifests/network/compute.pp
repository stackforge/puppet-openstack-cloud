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
# Network Compute node (Agent)
#

class privatecloud::network::compute(
  $neutron_endpoint = $os_params::ks_neutron_admin_host,
  $neutron_protocol = $os_params::ks_neutron_public_proto,
  $neutron_password = $os_params::ks_neutron_password,
) {

  class { 'nova::network::neutron':
      neutron_admin_password => $neutron_password,
      neutron_admin_auth_url => "${neutron_protocol}://${neutron_endpoint}:35357/v2.0",
      neutron_url            => "${neutron_protocol}://${neutron_endpoint}:9696"
  }

}
