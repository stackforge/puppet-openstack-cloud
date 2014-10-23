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
#   Deprecated.
#
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Defaults to ['physnet1:1000:2999']
#
# [*provider_bridge_mappings*]
#   Deprecated.
#
# [*flat_networks*]
#   (optionnal) List of physical_network names with which flat networks
#   can be created. Use * to allow flat networks with arbitrary
#   physical_network names.
#   Should be an array.
#   Default to ['public'].
#
# [*external_int*]
#   Deprecated.
#
# [*external_bridge*]
#   Deprecated.
#
# [*manage_ext_network*]
#   Deprecated.
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
#   Deprecated.
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
# [*plugin*]
#   (optional) Neutron plugin name
#   Supported values: 'ml2', 'n1kv'.
#   Defaults to 'ml2'
#
class cloud::network(
  $verbose                    = true,
  $debug                      = true,
  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',
  $api_eth                    = '127.0.0.1',
  $provider_vlan_ranges       = ['physnet1:1000:2999'],
  $use_syslog                 = true,
  $log_facility               = 'LOG_LOCAL0',
  $dhcp_lease_duration        = '120',
  $flat_networks              = ['public'],
  $tenant_network_types       = ['gre'],
  $type_drivers               = ['gre', 'vlan', 'flat'],
  $plugin                     = 'ml2',
  # only needed by cisco n1kv plugin
  $n1kv_vsm_ip                = '127.0.0.1',
  $n1kv_vsm_password          = 'secrete',
  $neutron_db_host            = '127.0.0.1',
  $neutron_db_user            = 'neutron',
  $neutron_db_password        = 'neutronpassword',
  $ks_keystone_admin_host     = '127.0.0.1',
  $ks_keystone_admin_proto    = 'http',
  $ks_keystone_admin_port     = 35357,
  $ks_neutron_password        = 'neutronpassword',
  # DEPRECATED PARAMETERS
  $tunnel_eth                 = false,
  $tunnel_types               = false,
  $provider_bridge_mappings   = false,
  $external_int               = false,
  $external_bridge            = false,
  $manage_ext_network         = false,
) {

  # Deprecated parameters warning
  if $tunnel_eth or $tunnel_types or $provider_bridge_mappings or $external_int or $external_bridge or $manage_ext_network {
    warning('This parameter is deprecated to move in cloud::network::vswitch class.')
  }

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

  case $plugin {
    'ml2': {
      $core_plugin = 'neutron.plugins.ml2.plugin.Ml2Plugin'
      class { 'neutron::plugins::ml2':
        type_drivers          => $type_drivers,
        tenant_network_types  => $tenant_network_types,
        network_vlan_ranges   => $provider_vlan_ranges,
        tunnel_id_ranges      => ['1:10000'],
        flat_networks         => $flat_networks,
        mechanism_drivers     => ['openvswitch','l2population'],
        enable_security_group => true
      }
    }

    'n1kv': {
      $core_plugin = 'neutron.plugins.cisco.network_plugin.PluginV2'
      class { 'neuton::plugins::cisco':
        database_user     => $neutron_db_user,
        database_password => $neutron_db_password,
        database_host     => $neutron_db_host,
        keystone_auth_url => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}/v2.0/",
        keystone_password => $ks_neutron_password,
        vswitch_plugin    => 'neutron.plugins.cisco.n1kv.n1kv_neutron_plugin.N1kvNeutronPluginV2',
      }
      neutron_plugin_cisco {
        'securitygroup/firewall_driver': value => 'neutron.agent.firewall.NoopFirewallDriver';
        "N1KV:${n1kv_vsm_ip}/username":  value  => 'admin';
        "N1KV:${n1kv_vsm_ip}/password":  value  => $n1kv_vsm_password;
        # TODO (EmilienM) not sure about this one:
        'database/connection':           value => "mysql://${neutron_db_user}:${neutron_db_password}@${neutron_db_host}/neutron";
      }
    }

    default: {
      err "${plugin} plugin is not supported."
    }
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
    core_plugin             => $core_plugin,
    service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
    log_dir                 => $log_dir,
    dhcp_lease_duration     => $dhcp_lease_duration,
    report_interval         => '30',
  }

}
