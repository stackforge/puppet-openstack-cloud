#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
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

import "params.pp"

# Import roles
import "roles/common/*.pp" # mandatory
import "roles/automation/*.pp"
import "roles/database/*.pp"
import "roles/identity/*.pp"
import "roles/messaging/*.pp"
import "roles/metering/*.pp"
import "roles/object-storage/*.pp"


node common {

# Params
  class{ "os_params": }

# Common system configuration
  class{ "os_common_system": }

}


# Puppet Master node
node 'os-ci-test2.enovance.com' inherits common{

# Everything related to puppet is bootstraped by jenkins
# and other stuffs are made by common class.

}

# Controller node
node 'os-ci-test3.enovance.com' inherits common{

## Databases:
    class {"mongodb_server":}
    class {"mysql_server":}

## Metering
#    class{'os_ceilometer_common':}
#    class{'os_ceilometer_server':}
    # Enforce using Ceilometer Agent central on one node (should be fixed in Icehouse):
#    class {"ceilometer::agent::central": }

## Identity 
    class {"os_keystone_server":
       local_ip => $ipaddress_eth0,
    }

# Object Storage
    class{'os_role_swift_proxy':
      local_ip => $ipaddress_eth0,
    }
    class {"os_role_swift_ringbuilder":
       rsyncd_ipaddress => $ipaddress_eth0,
    }
    Class["os_role_swift_ringbuilder"] -> Class["os_role_swift_proxy"]

# Messaging
    class{'os_role_rabbitmq': }

}

# Storage nodes
node 'os-ci-test8.enovance.com', 'os-ci-test9.enovance.com', 'os-ci-test12.enovance.com' inherits common{

## Metering
#    class{'os_ceilometer_common':}

## Object Storage
    class{ 'os_role_swift_storage':
        local_ip => $ipaddress_eth0,
        swift_zone    =>  $os_params::os_swift_zone[$::hostname],
    }
}
