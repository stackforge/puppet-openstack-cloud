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
# Network Metadata node
#

class os_network_metadata(
  $verbose                              = $os_params::verbose,
  $debug                                = $os_params::debug,
  $ks_neutron_password                  = $os_params::ks_neutron_password,
  $neutron_metadata_proxy_shared_secret = $os_params::neutron_metadata_proxy_shared_secret,
  $ks_nova_internal_host                = $os_params::ks_nova_internal_host,
  $ks_keystone_public_proto             = $os_params::ks_keystone_public_proto,
  $ks_keystone_public_port              = $os_params::ks_keystone_public_port,
  $ks_keystone_admin_host               = $os_params::ks_keystone_admin_host
) {

  class { 'neutron::agents::metadata':
    shared_secret => $neutron_metadata_proxy_shared_secret,
    verbose       => $verbose,
    debug         => $debug,
    metadata_ip   => $ks_nova_internal_host,
    auth_url      => "${ks_keystone_public_proto}://${ks_keystone_admin_host}:${ks_keystone_public_port}/v2.0",
    auth_password => $ks_neutron_password
  }

}
