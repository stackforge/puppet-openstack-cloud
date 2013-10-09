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
import "classes/apt_ubuntu_config.pp"
import "roles/*.pp"


node common {

# Params
  class{ "os_params": }

# APT repositories
  class{ "os_apt_config": }

# NTP
  if $hostname != "sm3-d" { # ntpserver
    class{ "ntp": 
    ntpservers => "sm3-d.${os_params::site_domain}"
    }
  }

# DNS
  $datacenter = 'au0'
  class{ "resolver":
    dcinfo      => { au0   => ['172.30.4.3'], },
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


# Controller node
node 'os-ci-test2.enovance.com' inherits common{

# Ceilometer
    class{'os_ceilometer':}

# Since Ceilometer Agent Central and Metadata Agent are SPOF, we need to run once to avoid problems:
    if $::fqdn == "os-ci-test2.enovance.com"  {
	class {"ceilometer::agent::central":
    	  auth_url      => "http://${os_params::ks_keystone_internal_host}:${os_params::keystone_port}/v2.0",
    	  auth_password => $os_params::ks_ceilometer_password,
	}
  package { "quantum-metadata-agent":
     ensure => latest,
  }
   }

# Keystone
    class {"os_role_keystone":
	local_ip => $ipaddress_eth1,
    }

# Swift Proxy
    class{'os_role_swift_proxy':
      local_ip => $ipaddress_eth1,
    }
    if $::fqdn == "sm4-c.os.osv.orange.internal"  {
	class {"os_role_swift_ringbuilder":
	    rsyncd_ipaddress => $ipaddress_eth1,
	}
	Class["os_role_swift_ringbuilder"] -> Class["os_role_swift_proxy"]
    }

# RabbitMQ
  class{'os_role_rabbitmq': }
}

# Swift Storage nodes
node 'sm1-b.os.osv.orange.internal', 'sm2-c.os.osv.orange.internal', 'sm3-c.os.osv.orange.internal' inherits common{
    class{ 'os_role_swift_storage':
        local_ip => $ipaddress_eth1,
        swift_zone    =>  $os_params::os_swift_zone[$::hostname],
    }
}
