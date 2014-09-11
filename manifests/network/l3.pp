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
# Network L3 node
#

class cloud::network::l3(
  $external_int     = 'eth1',
  $ext_provider_net = false,
  $debug            = true,
) {

  include 'cloud::network'

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
    debug                   => $debug,
    external_network_bridge => $external_network_bridge_real
  }

  class { 'neutron::agents::metering':
    debug => $debug,
  }

  # Disabling or not TSO/GSO/GRO on Debian systems
  if $::osfamily == 'Debian' and $::kernelmajversion >= '3.14' {
    ensure_resource ('exec','enable-tso-script', {
      'command' => '/usr/sbin/update-rc.d disable-tso defaults',
      'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
      'onlyif'  => 'test -f /etc/init.d/disable-tso'
    })
    ensure_resource ('exec','start-tso-script', {
      'command' => '/etc/init.d/disable-tso start',
      'unless'  => 'test -f /tmp/disable-tso-lock',
      'onlyif'  => 'test -f /etc/init.d/disable-tso'
    })
  }

}
