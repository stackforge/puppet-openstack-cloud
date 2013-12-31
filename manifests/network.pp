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
# == Class: privatecloud::network
#
# Common class for network nodes
#
# === Parameters:
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Default value in params
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Default value in params
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Default value in params
#
# [*debug*]
#   (optional) Set log output to debug output
#   Default value in params
#
# [*tunnel_eth*]
#   (optional) Which interface we connect to create overlay tunnels.
#   Default value in params
#

class privatecloud::network(
  $verbose             = $os_params::verbose,
  $debug               = $os_params::debug,
  $rabbit_hosts        = $os_params::rabbit_hosts,
  $rabbit_password     = $os_params::rabbit_password,
  $tunnel_eth          = $::ipaddress_eth0
) {

  class { 'neutron':
    allow_overlapping_ips   => true,
    verbose                 => $verbose,
    debug                   => $debug,
    rabbit_user             => 'neutron',
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_virtual_host     => '/',
    dhcp_agents_per_network => '2',
  }

  class { 'neutron::plugins::ovs':
    tenant_network_type   => 'gre',
    network_vlan_ranges   => false
  }

  class { 'neutron::agents::ovs':
    enable_tunneling => true,
    local_ip         => $tunnel_eth
  }

}
