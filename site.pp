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
# site.pp
#

import 'params.pp'

# Import manifests
import 'manifests/*.pp'
import 'manifests/compute/*.pp'
import 'manifests/database/*.pp'
import 'manifests/image/*.pp'
import 'manifests/monitoring/*.pp'
import 'manifests/network/*.pp'
import 'manifests/object-storage/*.pp'
import 'manifests/orchestration/*.pp'
import 'manifests/telemetry/*.pp'
import 'manifests/volume/*.pp'

node common {

# Params
  class { 'os_params': }

}


# Puppet Master node (x1)
node 'os-ci-test4', /pmaster\d+.enovance.com/ inherits common{

# Everything related to puppet is bootstraped by jenkins
# and other stuffs are made by common class.

}

# Controller nodes (x3)
node 'os-ci-test13', 'os-ci-test12', 'os-ci-test11', /mgmt\d+.enovance.com/ inherits common {

# os-ci-test13 is the main mgmt

## Load-Balancer:
    class {'privatecloud::loadbalancer':}

## Databases:
    class {'privatecloud::database::sql':}
    class {'privatecloud::database::nosql':}

## Dashboard:
    class {'privatecloud::dashboard':}

## Compute:
    class {'privatecloud::compute::controller':}

## Telemetry
    class {'os_telemetry_common':}
    class {'os_telemetry_server':}

## SPOF services
    class {'privatecloud::spof':}

## Identity
    class {'privatecloud::identity':
      local_ip => $ipaddress_eth0,
    }

# Object Storage
    class {'os_swift_proxy': }
    class {'os_swift_ringbuilder':
      rsyncd_ipaddress => $ipaddress_eth0,
    }
    Class['os_swift_ringbuilder'] -> Class['os_swift_proxy']

# Messaging
    class {'privatecloud::messaging': }

# Cache
    class {'privatecloud::cache': }

# Networking
    class {'os_network_common': }
    class {'os_network_controller': }

# Orchestration
    class {'os_orchestration_common': }
    class {'os_orchestration_api': }

}
#
# == Network nodes (x2)
# L2 integration providing several services: DHCP, L3 Agent, Metadata service, LBaaS, and VPNaaS
# We need at least two nodes for DHCP High availability
node 'os-ci-test8', /net\d+.enovance.com/ inherits common {

    class {'os_network_common': }
    class {'os_network_dhcp': }
    class {'os_network_metadata': }
    class {'os_network_lbaas': }
    class {'os_network_l3': }
    class {'os_network_vpn':}

}

# Storage nodes (x3)
node /storage\d+.enocloud.com/ inherits common{

## Telemetry
    class {'os_telemetry_common':}

## Object Storage
    class { 'os_swift_storage':
        local_ip    => $ipaddress_eth0,
        swift_zone  =>  $os_params::os_swift_zone[$::hostname],
    }
}

# Compute nodes (x1)
node 'os-ci-test10', /compute\d+.enovance.com/ inherits common {

## Networking
  class { 'os_network_common': }
  class { 'os_network_compute': }

## Compute
  class { 'privatecloud::compute::hypervisor':
    local_ip => $ipaddress_eth0,
  }

}
