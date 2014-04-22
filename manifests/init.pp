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
  $rhn_registration = undef,
) {

  if ! ($::osfamily in [ 'RedHat', 'Debian' ]) {
    fail("OS family unsuppored yet (${::osfamily}), module puppet-openstack-cloud only support RedHat or Debian")
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
    nameservers => ['8.8.8.8'],
    options     => 'UNSET',
    search      => 'example.com',
    domain      => 'example.com',
  }

# NTP
  class { 'ntp': servers => undef }

# Strong root password for all servers
  user { 'root':
    ensure           => 'present',
    gid              => '0',
    password         => 'root',
    uid              => '0',
  }

  $cron_service_name = $::osfamily ? {
    'RedHat' => 'crond',
    default  => 'cron',
  }

  service { 'cron':
    ensure => running,
    name   => $cron_service_name,
    enable => true
  }

  if $::osfamily == 'RedHat' and $rhn_registration {
    create_resources('rhn_register', {
      "rhn-${::hostname}" => $rhn_registration
    } )
  }
}
