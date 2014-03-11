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
# Class: cloud
#
# Installs the private cloud system requirements
#

class cloud(
  $rhn_registration = $os_params::rhn_registration,
) {

  if ! ($::osfamily in [ 'RedHat', 'Debian' ]) {
    fail("module puppet-cloud only support ${::osfamily}, only Red Hat or Debian")
  }

# motd
  file
  {
    '/etc/motd':
      ensure  => file,
      mode    => '0644',
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

# DNS
  class { 'dnsclient':
    nameservers => $os_params::dns_ips,
    options     => 'UNSET',
    search      => $os_params::site_domain,
    domain      => $os_params::site_domain,
  }

# NTP
  class { 'ntp': servers => $::os_params::ntp_servers }

# Strong root password for all servers
  user { 'root':
    ensure           => 'present',
    gid              => '0',
    password         => $os_params::root_password,
    uid              => '0',
  }

  service { 'cron':
    ensure => running,
    enable => true
  }

  if $::osfamily == 'RedHat' and $rhn_registration {
    create_resources('rhn_register', {
      $::hostname => $rhn_registration
    } )
  }
}
