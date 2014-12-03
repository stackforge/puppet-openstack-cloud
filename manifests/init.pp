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
# Installs the system requirements
#
class cloud(
  $rhn_registration     = undef,
  $root_password        = 'root',
  $dns_ips              = ['8.8.8.8', '8.8.4.4'],
  $site_domain          = 'mydomain',
  $motd_title           = 'eNovance IT Operations',
  $selinux_mode         = 'permissive',
  $selinux_directory    = '/usr/share/selinux',
  $selinux_booleans     = [],
  $selinux_modules      = [],
  $manage_firewall      = false,
  $firewall_rules       = {},
  $purge_firewall_rules = false,
  $firewall_pre_extras  = {},
  $firewall_post_extras = {},
  $validate_services    = false,
) {

  include ::stdlib

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
# ${motd_title} #
############################################################################
#                                                                          #
#                         *** RESTRICTED ACCESS ***                        #
#  Only the authorized users may access this system.                       #
#  Any attempted unauthorized access or any action affecting this computer #
#  system is punishable by the law of local country.                       #
#                                                                          #
############################################################################
This node is under the control of Puppet ${::puppetversion}.
";
  }

# DNS
  class { 'dnsclient':
    nameservers => $dns_ips,
    domain      => $site_domain
  }

# NTP
  include ::ntp

# SELinux
  if $::osfamily == 'RedHat' {
    class {'cloud::selinux' :
      mode      => $selinux_mode,
      booleans  => $selinux_booleans,
      modules   => $selinux_modules,
      directory => $selinux_directory,
      stage     => 'setup',
    }
  }

# Strong root password for all servers
  user { 'root':
    ensure   => 'present',
    gid      => '0',
    password => $root_password,
    uid      => '0',
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

  if $manage_firewall {

    # Only purges IPv4 rules
    if $purge_firewall_rules {
      resources { 'firewall':
        purge => true
      }
    }

    # anyone can add your own rules
    # example with Hiera:
    #
    # cloud::firewall::rules:
    #   '300 allow custom application 1':
    #     port: 999
    #     proto: udp
    #     action: accept
    #   '301 allow custom application 2':
    #     port: 8081
    #     proto: tcp
    #     action: accept
    #
    create_resources('cloud::firewall::rule', $firewall_rules)

    ensure_resource('class', 'cloud::firewall::pre', {
      'firewall_settings' => $firewall_pre_extras,
      'stage'             => 'setup',
    })

    ensure_resource('class', 'cloud::firewall::post', {
      'stage'             => 'runtime',
      'firewall_settings' => $firewall_post_extras,
    })
  }

}
