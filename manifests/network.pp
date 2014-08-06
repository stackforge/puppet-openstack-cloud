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
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*tunnel_eth*]
#   (optional) Which interface we connect to create overlay tunnels.
#   Defaults to '127.0.0.1'
#
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Defaults to ['physnet1:1000:2999']
#
# [*provider_bridge_mappings*]
#   (optionnal) Bridge mapping for provider networks
#   Defaults to ['physnet1:br-eth1']
#
# [*flat_networks*]
#   (optionnal) List of physical_network names with which flat networks
#   can be created. Use * to allow flat networks with arbitrary
#   physical_network names.
#   Should be an array.
#   Default to ['public'].
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
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#
# [*dhcp_lease_duration*]
#   (optional) DHCP Lease duration (in seconds)
#   Defaults to '120'
#
# [*tunnel_types*]
#   (optional) Handled tunnel types
#   Defaults to ['gre']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*tenant_network_types*]
#   (optional) Handled tenant network types
#   Defaults to ['gre']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*type_drivers*]
#   (optional) Drivers to load
#   Defaults to ['gre', 'vlan', 'flat']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#

class cloud::network(
  $verbose                  = true,
  $debug                    = true,
  $rabbit_hosts             = ['127.0.0.1:5672'],
  $rabbit_password          = 'rabbitpassword',
  $tunnel_eth               = '127.0.0.1',
  $api_eth                  = '127.0.0.1',
  $provider_vlan_ranges     = ['physnet1:1000:2999'],
  $provider_bridge_mappings = ['public:br-pub'],
  $use_syslog               = true,
  $log_facility             = 'LOG_LOCAL0',
  $dhcp_lease_duration      = '120',
  $flat_networks            = ['public'],
  $external_int             = 'eth1',
  $external_bridge          = 'br-pub',
  $manage_ext_network       = false,
  $tunnel_types             = ['gre'],
  $tenant_network_types     = ['gre'],
  $type_drivers             = ['gre', 'vlan', 'flat'],
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
    neutron_config {
      'DEFAULT/logging_context_format_string': value => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s';
      'DEFAULT/logging_default_format_string': value => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s';
      'DEFAULT/logging_debug_format_suffix': value => '%(funcName)s %(pathname)s:%(lineno)d';
      'DEFAULT/logging_exception_prefix': value => '%(process)d: TRACE %(name)s %(instance)s';
    }
  } else {
    $log_dir = '/var/log/neutron'
  }

  if $::osfamily == 'RedHat' {
    kmod::load { 'ip_gre': }
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
    dhcp_lease_duration     => $dhcp_lease_duration,
    report_interval         => '30',
  }

  class { 'neutron::agents::ovs':
    enable_tunneling => true,
    tunnel_types     => $tunnel_types,
    bridge_mappings  => $provider_bridge_mappings,
    local_ip         => $tunnel_eth
  }

  class { 'neutron::plugins::ml2':
    type_drivers          => $type_drivers,
    tenant_network_types  => $tenant_network_types,
    network_vlan_ranges   => $provider_vlan_ranges,
    tunnel_id_ranges      => ['1:10000'],
    flat_networks         => $flat_networks,
    mechanism_drivers     => ['openvswitch','l2population'],
    enable_security_group => true
  }

  # TODO(EmilienM) Temporary, need to be fixed upstream.
  # There is an issue when using ML2 + OVS: neutron services don't read OVS
  # config file, only ML2. I need to patch puppet-neutron.
  # Follow-up: https://github.com/enovance/puppet-openstack-cloud/issues/199
  neutron_plugin_ml2 {
    'agent/tunnel_types':            value => $tunnel_types;
    'agent/l2_population':           value => true;
    'agent/polling_interval':        value => '15';
    'OVS/local_ip':                  value => $tunnel_eth;
    'OVS/enable_tunneling':          value => true;
    'OVS/integration_bridge':        value => 'br-int';
    'OVS/tunnel_bridge':             value => 'br-tun';
    'OVS/bridge_mappings':           value => $provider_bridge_mappings;
    'securitygroup/firewall_driver': value => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver';
  }

  # TODO(EmilienM), Temporary, it's a bug in Debian packages. GH#342
  file { '/var/lib/neutron':
      ensure => 'directory',
      owner  => 'neutron',
      group  => 'neutron',
      mode   => '0755'
  }

  if $manage_ext_network {
    vs_port {$external_int:
      ensure => present,
      bridge => $external_bridge
    }
    if defined('neutron::server') {
      neutron_network {'public':
        provider_network_type     => 'flat',
        provider_physical_network => 'public',
        shared                    => true,
        router_external           => true
      }
    }
  }

}
