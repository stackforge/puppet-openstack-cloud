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
# Network vswitch class
#
# === Parameters:
#
# [*driver*]
#   (optional) Neutron vswitch driver
#   Currently, only ml2_ovs is supported.
#   Defaults to 'ml2_ovs'
#
# [*tunnel_eth*]
#   (optional) Interface IP used to build the tunnels
#   Defaults to '127.0.0.1'
#
# [*tunnel_typeis]
#   (optional) List of types of tunnels to use when utilizing tunnels
#   Defaults to ['gre']
#
# [*provider_bridge_mappings*]
#   (optional) List of <physical_network>:<bridge>
#
# [*external_int*]
#   (optionnal) Network interface to bind the external provider network
#   Defaults to 'eth1'.
#
# [*external_bridge*]
#   (optionnal) OVS bridge used to bind external provider network
#   Defaults to 'br-pub'.
#
# [*manage_ext_network*]
#   (optionnal) Manage or not external network with provider network API
#   Defaults to false.
#

class cloud::network::vswitch(
  $driver                   = 'ml2_ovs',
  $tunnel_types             = ['gre'],
  $provider_bridge_mappings = ['public:br-pub'],
  $tunnel_eth               = '127.0.0.1',
  $manage_ext_network       = false,
  $external_int             = 'eth1',
  $external_bridge          = 'br-pub',
) {

  include 'cloud::network'

  if $driver == 'ml2_ovs' {
    class { 'neutron::agents::ml2::ovs':
      enable_tunneling => true,
      l2_population    => true,
      polling_interval => '15',
      tunnel_types     => $tunnel_types,
      bridge_mappings  => $provider_bridge_mappings,
      local_ip         => $tunnel_eth
    }

    if $::osfamily == 'RedHat' {
      kmod::load { 'ip_gre': }
    }

    if $manage_ext_network {
      vs_port {$external_int:
        ensure => present,
        bridge => $external_bridge
      }
    }
  }

}
