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
# Network Metadata node (need to be run once)
# Could be managed by spof_node manifest
#

class cloud::network::metadata(
  $enabled                              = true,
  $debug                                = true,
  $ks_neutron_password                  = 'neutronpassword',
  $neutron_metadata_proxy_shared_secret = 'asecreteaboutneutron',
  $nova_metadata_server                 = '127.0.0.1',
  $ks_keystone_admin_proto              = 'http',
  $ks_keystone_admin_port               = 35357,
  $ks_keystone_admin_host               = '127.0.0.1',
  $auth_region                          = 'RegionOne',
  $ks_nova_internal_proto               = 'http'
) {

  include 'cloud::network'

  class { 'neutron::agents::metadata':
    enabled          => $enabled,
    shared_secret    => $neutron_metadata_proxy_shared_secret,
    debug            => $debug,
    metadata_ip      => $nova_metadata_server,
    auth_url         => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}/v2.0",
    auth_password    => $ks_neutron_password,
    auth_region      => $auth_region,
    metadata_workers => $::processorcount
  }

  neutron_metadata_agent_config {
    'DEFAULT/nova_metadata_protocol': value => $ks_nova_internal_proto;
  }

}
