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
# Swift ring builder node
#

class privatecloud::object::ringbuilder(
    $rsyncd_ipaddress            = ipaddress_eth0,
    $replicas                    = $os_params::replicas,
    $swift_rsync_max_connections = $os_params::swift_rsync_max_connections,
) {

  Ring_object_device <<| |>>
  Ring_container_device <<| |>>
  Ring_account_device <<| |>>

  Class['swift'] -> Class['os_swift_ringbuilder']

  swift::ringbuilder::create{ ['account', 'container']:
    part_power     => 9,
    replicas       => $replicas,
    min_part_hours => 24,
  }

  swift::ringbuilder::create{'object':
    part_power     => 15,
    replicas       => $replicas,
    min_part_hours => 24,
  }

  Swift::Ringbuilder::Create['object'] -> Ring_object_device <| |> ~> Swift::Ringbuilder::Rebalance['object']
  Swift::Ringbuilder::Create['container'] -> Ring_container_device <| |> ~> Swift::Ringbuilder::Rebalance['container']
  Swift::Ringbuilder::Create['account'] -> Ring_account_device <| |> ~> Swift::Ringbuilder::Rebalance['account']

  swift::ringbuilder::rebalance{ ['object', 'account', 'container']: }

  class { 'rsync::server':
    use_xinetd => true,
    address    => $rsyncd_ipaddress,
    use_chroot => 'no',
  }

  Rsync::Server::Module {
    incoming_chmod  => 'u=rwX,go=rX',
    outgoing_chmod  => 'u=rwX,go=rX',
  }

  rsync::server::module { 'swift_server':
    path            => '/etc/swift',
    lock_file       => '/var/lock/swift_server.lock',
    uid             => 'swift',
    gid             => 'swift',
    max_connections => $swift_rsync_max_connections,
    read_only       => true,
  }

  # exports rsync gets that can be used to sync the ring files
  @@swift::ringsync { ['account', 'object', 'container']:
    ring_server => $rsyncd_ipaddress,
  }
}

