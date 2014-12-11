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
# == Class: cloud::storage::rbd::libvirt
#
# Configure Ceph RBD in libvirt
#
# === Parameters:
#
# [*ceph_fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
class cloud::storage::rbd::libvirt(
  $ceph_fsid
) {
  @@file { '/etc/ceph/secret.xml':
    content => template('cloud/storage/ceph/secret-compute.xml.erb'),
    tag     => 'ceph_compute_secret_file',
  }

  if $::osfamily == 'RedHat' {
    $libvirt_package_name = 'libvirt'
  } else {
    $libvirt_package_name = 'libvirt-bin'
  }

  @@exec { 'get_or_set_virsh_secret':
    command => 'virsh secret-define --file /etc/ceph/secret.xml',
    unless  => "virsh secret-list | tail -n +3 | cut -f1 -d' ' | grep -sq ${ceph_fsid}",
    tag     => 'ceph_compute_get_secret',
    require => [Package[$libvirt_package_name],File['/etc/ceph/secret.xml']],
    notify  => Exec['set_secret_value_virsh'],
  }

  @@exec { 'set_secret_value_virsh':
    command     => "virsh secret-set-value --secret ${ceph_fsid} --base64 ${::ceph_keyring_cinder}",
    tag         => 'ceph_compute_set_secret',
    refreshonly =>  true,
  }
}
