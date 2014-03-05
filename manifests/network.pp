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
# == Class: cloud::network
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
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Default value in params
#
# [*provider_bridge_mappings*]
#   (optionnal) Bridge mapping for provider networks
#   Default value in params
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults value in params
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults value in params
#

class cloud::network(
  $verbose                  = $os_params::verbose,
  $debug                    = $os_params::debug,
  $rabbit_hosts             = $os_params::rabbit_hosts,
  $rabbit_password          = $os_params::rabbit_password,
  $tunnel_eth               = $os_params::tunnel_eth,
  $api_eth                  = $os_params::api_eth,
  $provider_vlan_ranges     = $os_params::provider_vlan_ranges,
  $provider_bridge_mappings = $os_params::provider_bridge_mappings,
  $use_syslog               = $os_params::use_syslog,
  $log_facility             = $os_params::log_facility
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/neutron'
  }

  class { 'neutron':
    allow_overlapping_ips   => true,
    verbose                 => $verbose,
    debug                   => $debug,
    rabbit_user             => 'neutron',
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_virtual_host     => '/',
    bind_host               => $api_eth,
    log_facility            => $log_facility,
    use_syslog              => $use_syslog,
    dhcp_agents_per_network => '2',
    core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
    service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
    log_dir                 => $log_dir,
  }

  class { 'neutron::agents::ovs':
    enable_tunneling => true,
    tunnel_types     => ['gre'],
    bridge_mappings  => $provider_bridge_mappings,
    local_ip         => $tunnel_eth
  }

  class { 'neutron::plugins::ml2':
    type_drivers          => ['gre','vlan'],
    tenant_network_types  => ['gre'],
    network_vlan_ranges   => $provider_vlan_ranges,
    tunnel_id_ranges      => ['1:10000'],
    mechanism_drivers     => ['openvswitch','l2population'],
    enable_security_group => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
  }

  # TODO(EmilienM) Temporary, need to be fixed upstream.
  # There is an issue when using ML2 + OVS: neutron services don't read OVS
  # config file, only ML2. I need to patch puppet-neutron.
  # Follow-up: https://github.com/enovance/puppet-cloud/issues/199
  neutron_plugin_ml2 {
    'agent/tunnel_types':     value => ['gre'];
    'agent/l2_population':    value => true;
    'agent/polling_interval': value => '2';
    'OVS/local_ip':           value => $tunnel_eth;
    'OVS/enable_tunneling':   value => true;
    'OVS/integration_bridge': value => 'br-int';
    'OVS/tunnel_bridge':      value => 'br-tun';
    'OVS/bridge_mappings':    value => $provider_bridge_mappings;
  }

  # TODO(EmilienM), Temporary, it's a bug in Debian packages. GH#342
  file { "/var/lib/neutron":
      ensure => "directory",
      owner  => "neutron",
      group  => "neutron",
      mode   => 755,
  }

}
