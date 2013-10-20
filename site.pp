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
import "classes/authorized_keys.pp"

# Import roles
import "roles/automation/*.pp"
import "roles/database/*.pp"
import "roles/identity/*.pp"
import "roles/messaging/*.pp"
import "roles/metering/*.pp"
import "roles/object-storage/*.pp"

# Install packages or not
if $os_params::install_packages == True {
  case $operatingsystem {
    debian: { import "classes/apt_debian_config.pp" }
#    ubuntu: { import "classes/apt_ubuntu_config.pp" }
    default: { fail("Unrecognized operating system") }
  }
}

node common {

# Params
  class{ "os_params": }

# APT repositories
if $os_params::install_packages {
  class{ "os_apt_config": }
}

# DNS
  $datacenter = 'ci'
  class{ "resolver":
    dcinfo      => { ci   => ['10.68.0.2'], },
    domainname  => "${os_params::site_domain}",
    searchpath  => "${os_params::site_domain}.",
  }

# SSH Keys
  package { "enovance-config-sshkeys-dev":
      ensure => "installed"
  }

# Strong root password for all servers
  user { 'root':
    ensure           => 'present',
    gid              => '0',
    password         => $os_params::root_password,
    uid              => '0',
  }

}


# Puppet Master node
node 'os-ci-test2.enovance.com' inherits common{

## Automation
    class{'os_puppet_master':}

}

# Controller node
node 'os-ci-test3.enovance.com' inherits common{

## Automation
    class{'os_puppet_master':}

## Databases:
    class {"mongodb_server":}
    class {"mysql_server":}

## Metering
    class{'os_ceilometer_server':}
    # Enforce using Ceilometer Agent central on one node (should be fixed in Icehouse):
zsh:1: command not found: q

## Identity 
    class {"os_keystone_server":
       local_ip => $ipaddress_eth1,
    }

## Object Storage
    class{'os_role_swift_proxy':
      local_ip => $ipaddress_eth1,
    }
    class {"os_role_swift_ringbuilder":
       rsyncd_ipaddress => $ipaddress_eth1,
    }
    Class["os_role_swift_ringbuilder"] -> Class["os_role_swift_proxy"]

## Messaging
    class{'os_role_rabbitmq': }

}

# Storage nodes
node 'os-ci-test6.enovance.com', 'os-ci-test12.enovance.com', 'os-ci-test13.enovance.com' inherits common{

## Metering
    class{'os_ceilometer_common':}

## Object Storage
    class{ 'os_role_swift_storage':
        local_ip => $ipaddress_eth1,
        swift_zone    =>  $os_params::os_swift_zone[$::hostname],
    }
}
