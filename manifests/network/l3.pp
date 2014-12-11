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
# == Class:
#
# Network L3 node
#
# === Parameters:
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*ext_provider_net*]
#   (optional) Manage L3 with another provider
#   Defaults to false
#
# [*external_int*]
#   (optional) The name of the external nic
#   Defaults to eth1
#
# [*manage_tso*]
#  (optional) Disable TSO on Neutron interfaces
#  Defaults to true
#
# [*ha_enabled*]
#   (optional) Enable HA for L3 agent or not.
#   Defaults to false
#
# [*ha_vrrp_auth_type*]
#   (optional) VRRP authentication type. Can be AH or PASS.
#   Defaults to "PASS"
#
# [*ha_vrrp_auth_password*]
#   (optional) VRRP authentication password. Required if ha_enabled = true.
#   Defaults to undef
#
# [*allow_automatic_l3agent_failover*]
#   (optional) Automatically reschedule routers from offline L3 agents to online
#   L3 agents.
#   Defaults to 'False'
#
# [*agent_mode*]
#   (optional) The working mode for the agent.
#   'legacy': default behavior (without DVR)
#   'dvr': enable DVR for an L3 agent running on compute node (DVR in production)
#   'dvr_snat': enable DVR with centralized SNAT support (DVR for single-host, for testing only)
#   Right now, DVR is not compatible with ha_enabled
#   Defaults to 'legacy'
#
class cloud::network::l3(
  $external_int     = 'eth1',
  $ext_provider_net = false,
  $debug            = true,
  $manage_tso       = true,
  $ha_enabled                       = false,
  $ha_vrrp_auth_type                = 'PASS',
  $ha_vrrp_auth_password            = undef,
  $allow_automatic_l3agent_failover = false,
  $agent_mode                       = 'legacy',

) {

  include 'cloud::network'
  include 'cloud::network::vswitch'

  if $ha_enabled and $agent_mode != 'legacy' {
    fail ('ha_enabled requires agent_mode to be set to legacy')
  }

  if ! $ext_provider_net {
    vs_bridge{'br-ex':
      external_ids => 'bridge-id=br-ex',
    } ->
    vs_port{$external_int:
      ensure => present,
      bridge => 'br-ex'
    }
    $external_network_bridge_real = 'br-ex'
  } else {
    $external_network_bridge_real = ''
  }

  class { 'neutron::agents::l3':
    debug                            => $debug,
    external_network_bridge          => $external_network_bridge_real,
    ha_enabled                       => $ha_enabled,
    ha_vrrp_auth_type                => $ha_vrrp_auth_type,
    ha_vrrp_auth_password            => $ha_vrrp_auth_password,
    allow_automatic_l3agent_failover => $allow_automatic_l3agent_failover,
    agent_mode                       => $agent_mode,
  }

  class { 'neutron::agents::metering':
    debug => $debug,
  }

  # Disabling TSO/GSO/GRO
  if $manage_tso {
    if $::osfamily == 'Debian' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/update-rc.d disable-tso defaults',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    } elsif $::osfamily == 'RedHat' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/chkconfig disable-tso on',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    }
    ensure_resource ('exec','start-tso-script', {
      'command' => '/etc/init.d/disable-tso start',
      'unless'  => '/usr/bin/test -f /var/run/disable-tso.pid',
      'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
    })
  }

}
