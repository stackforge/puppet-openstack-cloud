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
# Hypervisor Compute node
#

class os_compute_hypervisor(
  $local_ip          = $ipaddress_eth1,
  $libvirt_type      = 'kvm',
) {

  include 'os_compute_common'

  exec { 'insert_module_nbd':
    command => '/bin/echo "nbd" > /etc/modules',
    unless  => '/bin/grep "nbd" /etc/modules',
  }

  exec { '/sbin/modprobe nbd':
    unless => '/bin/grep -q "^nbd " "/proc/modules"'
  }

  file{ '/var/lib/nova/.ssh':
    ensure  => directory,
    mode    => '0700',
    owner   => 'nova',
    group   => 'nova',
    require => Class['nova']
  } ->
  file{ '/var/lib/nova/.ssh/id_rsa':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => $os_params::nova_ssh_private_key
  } ->
  file{ '/var/lib/nova/.ssh/authorized_keys':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => $os_params::nova_ssh_public_key
  } ->
  file{ '/var/lib/nova/.ssh/config':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => "
Host *
    StrictHostKeyChecking no
"
  }

  class { 'nova::compute':
    enabled     => true,
    vnc_enabled => false,
  }

  class { 'nova::compute::libvirt':
    libvirt_type      => $libvirt_type,
    vncserver_listen  => '0.0.0.0',
    migration_support => true,
  }

  exec{'/etc/init.d/open-iscsi start':
    onlyif => '/bin/grep "GenerateName=yes" /etc/iscsi/initiatorname.iscsi'
  }
  exec{'/etc/init.d/open-iscsi stop':
    subscribe   => Exec['/etc/init.d/open-iscsi start'],
    refreshonly => true
  }

  class { '::nova::compute::spice':
    agent_enabled              => true,
    server_listen              => '0.0.0.0',
    server_proxyclient_address => $local_ip,
    proxy_protocol             => $os_params::ks_nova_public_proto,
    proxy_host                 => $os_params::ks_nova_public_host,
  }

}
