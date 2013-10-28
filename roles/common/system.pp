#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Emilien Macchi <emilien.macchi@enovance.com>
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
# Operating System
#

class os_common_system{

# motd
  file
  {
    '/etc/motd':
      ensure  => file,
      mode    => 644,
      content => "
############################################################################
#                           eNovance IT Operations                         #
############################################################################
#                                                                          #
#                         *** RESTRICTED ACCESS ***                        #
#  Only the authorized users may access this system.                       #
#  Any attempted unauthorized access or any action affecting the computer  #
#  system of eNovance is punishable under articles 323-1 to 323-7 of       #
#  French criminal law.                                                    #
#                                                                          #
############################################################################
This node is under the control of Puppet ${::puppetversion}.
";
  }

# APT repositories
  class{ "os_packages_config": }

# DNS
  $datacenter = 'ci'
  class{ "resolver":
    dcinfo      => { ci   => ['10.68.0.2'], },
    domainname  => "${os_params::site_domain}",
    searchpath  => "${os_params::site_domain}.",
  }

# NTP
  class { '::ntp':
    servers => [ '0.fr.pool.ntp.org', '0.us.pool.ntp.org' ],
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
