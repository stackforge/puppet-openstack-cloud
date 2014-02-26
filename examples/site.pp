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
# This is an example of site.pp to deploy OpenStack using puppet-cloud.
#
# It follow our reference archiecture where we have:
#   - 2 load-balancers
#   - 3 controllers
#   - 2 network nodes
#   - 3 swift storage nodes
#   - 3 ceph storage nodes
#   - 2 compute nodes
#

import 'params.pp'

node common {

## Params
  class {'os_params':}
  class {'cloud':}

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  }

}

# Controller nodes (x3)
# Our reference architecture suggest having at least 3 controllers
node controller1, controller2, controller3 inherits common {

## Database services
## We install here MySQL Galera for all OpenStack databases
## except for MongoDB where we use replicaset
  class {'cloud::database::sql':}
  class {'cloud::database::nosql':}

## Dashboard:
  class {'cloud::dashboard':}

## Compute:
  class {'cloud::compute::controller':}

## Volume:
  class {'cloud::volume::controller':}
  class {'cloud::volume::storage':}

## SPOF services
## Some OpenStack are single point of failure (SPOF), this class aims
## to manage them with Pacekamer/Corosync.
  class {'cloud::spof':}

## Cache
  class {'cloud::cache': }

## Image:
  class {'cloud::image':}

## Telemetry
  class {'cloud::telemetry::server':}

## Identity
  class {'cloud::identity':}

## Object Storage
  class {'cloud::object::controller': }

  # Ring build must be activated only on one mgmt
  # please see https://github.com/enovance/puppet-cloud/issues/29
  if $::hostname == $os_params::mgmt_names[0] {
    class {'cloud::object::ringbuilder':
      rsyncd_ipaddress => $internal_netif_ip,
    }
    Class['cloud::object::ringbuilder'] -> Class['cloud::object::controller']
  }

## Messaging
  class {'cloud::messaging': }

## Networking
  class {'cloud::network::controller': }

## Orchestration
  class {'cloud::orchestration::api': }

## Ceph monitor
  class { 'cloud::storage::rbd::monitor':
    id       => "${::uniqueid}_${::hostname}",
    mon_addr => $os_params::internal_netif_ip
  }

  # Ceph admin key
  if $::hostname == $os_params::mgmt_names[0] {
    if !empty($::ceph_admin_key) {
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }

    # Ceph pools (cinder/glance)
    class { 'cloud::storage::rbd::pools':
      setup_pools => true,
      ceph_fsid   => $::os_params::ceph_fsid,
    }
  }

}

# Load balancer node (x2)
node loadbalancer1 inherits common {
  class {'cloud::loadbalancer':
    keepalived_state => 'MASTER'
  }
}
node loadbalancer2 inherits common {
  class {'cloud::loadbalancer':
    keepalived_state => 'BACKUP'
  }
}

# Network nodes (x2)
# L2 integration providing several services: DHCP, L3 Agent, Metadata service, LBaaS, and VPNaaS
# We need at least two nodes for DHCP High availability
node network1, network2 inherits common {

## Networking
  class {'cloud::network::dhcp': }
  class {'cloud::network::metadata': }
  class {'cloud::network::lbaas': }
  class {'cloud::network::l3': }
  class {'cloud::network::vpn':}

}

# Swift Storage nodes (x3)
node swiftstore1, swiftstore2, swiftstore3 inherits common{

## Telemetry
  class {'cloud::telemetry':}

## Object Storage
  class { 'cloud::object::storage':
    swift_zone  =>  $os_params::os_swift_zone[$::hostname],
  }

}

# Compute nodes (x2)
node compute1, compute2 inherits common {

## Compute
  class { 'cloud::compute::hypervisor':
    has_ceph => $os_params::compute_has_ceph;
  }

}

# Ceph Storage nodes (x3) (Ceph, mon + osd)
node cephstore1, cephstore2, cephstore3 inherits common {

## Ceph OSD
  class { 'cloud::storage::rbd::osd':
    public_address  => $os_params::public_netif_ip,
    cluster_address => $os_params::storage_netif_ip,
    devices         => $os_params::ceph_osd_devices,
  }

}
