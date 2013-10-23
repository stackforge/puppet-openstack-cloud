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
#                          *** ACCÈS RESTREINT ***                         #
#  L'accès à ce système est réservé aux seules personnes autorisées.       #
#  Toute tentative d'accès frauduleux ou tout agissement portant atteinte  #
#  aux systèmes de traitement automatisé de données de Cloudwatt expose    #
#  son auteur à des poursuites pénales au titre des articles 323-1 à 323-7 #
#  du Code Pénal.                                                          #
#                                                                          #
#                         *** RESTRICTED ACCESS ***                        #
#  Only the authorized users may access this system.                       #
#  Any attempted unauthorized access or any action affecting the computer  #
#  system of Cloudwatt is punishable under articles 323-1 to 323-7 of      #
#  French criminal law.                                                    #
#                                                                          #
############################################################################
This node is under the control of Puppet ${::puppetversion}.
";
  }

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
