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

# site.pp


import "params.pp"
import "classes/authorized_keys.pp"
import "roles/*.pp"

# Install packages or not
if $os_params::install_packages {
  case $operatingsystem {
    debian: { import "classes/apt_debian_config.pp" }
    ubuntu: { import "classes/apt_ubuntu_config.pp" }
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

# NTP
  class{ "ntp": ntpservers => "os-ci-admin.ring..${os_params::site_domain}" }

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


# Cloud Controller node
node 'os-ci-test2.enovance.com' inherits common{

# Puppet Master
    class{'os_puppet_master':}

# Databases:
    class {"mongodb_server":}
    class {"mysql_server":}

# Ceilometer
    class{'os_ceilometer_server':}
    # Enforce using Ceilometer Agent central on one node (should be fixed in Icehouse):
    class {"ceilometer::agent::central":
       auth_url      => "http://${os_params::ks_keystone_internal_host}:${os_params::keystone_port}/v2.0",
       auth_password => $os_params::ks_ceilometer_password,
    }

# Keystone
    class {"os_keystone_server":
       local_ip => $ipaddress_eth1,
    }

# Swift Proxy
    class{'os_role_swift_proxy':
      local_ip => $ipaddress_eth1,
    }
    class {"os_role_swift_ringbuilder":
       rsyncd_ipaddress => $ipaddress_eth1,
    }
    Class["os_role_swift_ringbuilder"] -> Class["os_role_swift_proxy"]

# RabbitMQ
  class{'os_role_rabbitmq': }
}

# Swift Storage nodes
node 'os-ci-test3.enovance.com', 'os-ci-test4.enovance.com', 'os-ci-test5.enovance.com' inherits common{

    class{'os_ceilometer_common':}

    class{ 'os_role_swift_storage':
        local_ip => $ipaddress_eth1,
        swift_zone    =>  $os_params::os_swift_zone[$::hostname],
    }
}
