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
# == Class: cloud::compute::hypervisor
#
# Hypervisor Compute node
#
# === Parameters:
#
# [*has_ceph]
#   (optional) Enable or not ceph capabilities on compute node.
#   If Ceph is used as a backend for Cinder or Nova, this option should be
#   set to True.
#   Default to false.
#

class cloud::compute::hypervisor(
  $server_proxyclient_address = '127.0.0.1',
  $libvirt_type               = 'kvm',
  $ks_nova_public_proto       = 'http',
  $ks_nova_public_host        = '127.0.0.1',
  $nova_ssh_private_key       = '
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEAy0QCW1bYo1jLDrkqRp2qIi4HcY2ZThG/D0zR4I2eWSkEXRnX
  F/cOerM8BLYoCOa2BAXunSIEaCuL8kfLD1hk8LS1Pmn/1q+byJyYODAzWHhHQ6Hj
  lrv/tXeyrQzva84u+kK5eBvrQ61cc0GknACa9E4iRO05BMn4mNb8CgY8/8UzMItw
  lyHkA4MguI2l3qO98PBYqhT06+CQC7ZsbtDJdfkBCBMrGWfpSXgfV/moJQWR3nO9
  iSr1Rg1fLsDTSw0XDQIINcdlyArUraWFTzG5GI/ulaxgDqaZMBeD3Ms4bV54O/kU
  sjwKEJKjy8jfiDorrPw4uIfC7yq+NbPZoPEzJQIDAQABAoIBAQCIo2wOKIAytiKy
  AAkKNTxEA7sfOzd+AnH0AAjpsWlruCXly9QKmRpTox7KcATTjvt2EuLHIDHkMLm/
  oUFATIR2RpO7pBfGIoBPR+0PgF9Trm8BaNcL4c7QFum2aIadapmrw6TXt7Tb5rLK
  C6ty7vk7Fzb0LJ9yt650V7hPqMfiimPXaEK5ar9AdONdsCdozBzvLGse4kfcUuLA
  rpIWe5UasbInqv1Gnan7yry6DogQOON0WYtXb6VWmINGW04l0Cr68YhrB9N9XRIG
  QpjFdnoL8tJ7bc6PISnHh14J2xIrN95DguZBDM0VDSyv/LhP8e4GSfOezLqVr1KG
  kbf3T+V1AoGBAOfSSSwLPJKPegbnwrwh4KNUt3J1x3RJAtniNYZ3T69aO3jC4Z7q
  0ZKZE6Nwhb6pogaqi1cizeGzSxbFNmYGHLuL/DkkBKYcha1KMJwliZ5R45SLS63Y
  DTyRcqEJ1Hu3fJa/Onst87c5fPfs//4WrGPXy3XdIfzQnxuP0FHQ7A5zAoGBAOB3
  RjZthPUoQqc4j5yvUwHQOlmqXdyYpWi9bh/jxbg+vZ1SNYu7JGCSHQqjjnec17M4
  ntdkrbFQp5+EyOWnRPiu0Mg6Be54VBiIrAhxSs6t+8Fi4dORfT/FMV+Q1b4b9mhx
  kzMEqyqiokGlTnjO7ZXbjDm8/KtqbkcBMEK1fnoHAoGAFHopxn8zmYqc79E3DWE8
  s5C/J5gpxybP3qkxqzAM1ON2j2M/hMcfPgDRkEVXOxFG46na5xaG8yHgRyGifX6a
  uSJTZES/OGEamcUM6C4Uqux22t83DyMfgDMk2f7BSzBZDAPWSZ00gwHL/SZtMmeU
  ULl2GnIvF2LiOxAICcIXp+sCgYEAlGcnO5ri+bbZgndJs5zSs3M48MlLbypYycvc
  ACd2NF7+vAF7N1vOLC7OFpeV/Izsqyg3FE8S6xVZDYUb0YHqfsQNcyOxgj151BKg
  MqC8hbLPrMa0aU1aUowMHZPDTQJtwhW87VEb3X9S6TXikMq2l4pkxlOldatTJ4yo
  nKIj8YcCgYA7WQEKryuZ2XPbdgVxP53diBrA7nmBoAos0T6c6BiAdMjy0M/G6Mm0
  8DQzqT/bEvqADKsabFu341euma7UOWFnf8MM1uWGp1PiDf0B6mO6z3kbE0XW1QpF
  2Y7b3faqSiFnbeaDtPUl+aAFB00uvc3NyRSB1cKghScWw3REjlqMRg==
  -----END RSA PRIVATE KEY-----
  ',
  $nova_ssh_public_key        = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLRAJbVtijWMsOuSpGnaoiLgdxjZlOEb8PTNHgjZ5ZKQRdGdcX9w56szwEtigI5rYEBe6dIgRoK4vyR8sPWGTwtLU+af/Wr5vInJg4MDNYeEdDoeOWu/+1d7KtDO9rzi76Qrl4G+tDrVxzQaScAJr0TiJE7TkEyfiY1vwKBjz/xTMwi3CXIeQDgyC4jaXeo73w8FiqFPTr4JALtmxu0Ml1+QEIEysZZ+lJeB9X+aglBZHec72JKvVGDV8uwNNLDRcNAgg1x2XICtStpYVPMbkYj+6VrGAOppkwF4PcyzhtXng7+RSyPAoQkqPLyN+IOius/Di4h8LvKr41s9mg8TMl nova@openstack',
  $spice_port                 = 6082,
  $cinder_rbd_user            = 'cinder',
  $nova_rbd_pool              = 'volumes',
  $nova_rbd_secret_uuid       = '4a158d27-f750-41d5-9e7f-26ce4c9d2d45',
  $has_ceph                   = false
) {

  include 'cloud::compute'
  include 'cloud::telemetry'
  include 'cloud::network'

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
    content => $nova_ssh_private_key
  } ->
  file{ '/var/lib/nova/.ssh/authorized_keys':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => $nova_ssh_public_key
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
    enabled         => true,
    vnc_enabled     => false,
    #TODO(EmilienM) Bug #1259545 currently WIP:
    virtio_nic      => false,
    neutron_enabled => true
  }

  class { 'nova::compute::spice':
    server_listen              => '0.0.0.0',
    server_proxyclient_address => $server_proxyclient_address,
    proxy_host                 => $ks_nova_public_host,
    proxy_protocol             => $ks_nova_public_proto,
    proxy_port                 => $spice_port

  }

  if $::operatingsystem == 'RedHat' {
    file { '/etc/libvirt/qemu.conf':
      ensure => file,
      source => 'puppet:///modules/cloud/qemu/qemu.conf',
      owner  => root,
      group  => root,
      mode   => '0644',
      notify => Service['libvirtd']
    }
  }

  if $::operatingsystem == 'Ubuntu' {
    service { 'dbus':
      ensure => running,
      enable => true,
      before => Class['nova::compute::libvirt'],
    }
  }

  Service<| title == 'dbus' |> { enable => true }

  Service<| title == 'libvirt-bin' |> { enable => true }

  class { 'nova::compute::neutron': }

  if $has_ceph {

    $libvirt_disk_cachemodes_real = ['network=writeback']
    include 'cloud::storage::rbd'

    # TODO(EmilienM) Temporary, while https://review.openstack.org/#/c/72440 got merged
    nova_config {
      'DEFAULT/libvirt_images_type':          value => 'rbd';
      'DEFAULT/libvirt_images_rbd_pool':      value => $nova_rbd_pool;
      'DEFAULT/libvirt_images_rbd_ceph_conf': value => '/etc/ceph/ceph.conf';
      'DEFAULT/rbd_user':                     value => $cinder_rbd_user;
      'DEFAULT/rbd_secret_uuid':              value => $nova_rbd_secret_uuid;
    }

    File <<| tag == 'ceph_compute_secret_file' |>>
    Exec <<| tag == 'get_or_set_virsh_secret' |>>
    Exec <<| tag == 'set_secret_value_virsh' |>>

    # Configure Ceph keyring
    Ceph::Key <<| title == $cinder_rbd_user |>>

    # If Cinder & Nova reside on the same node, we need a group
    # where nova & cinder users have read permissions.
    ensure_resource('group', 'cephkeyring', {
      ensure => 'present'
    })

    ensure_resource ('exec','add-nova-to-group', {
      'command' => 'usermod -a -G cephkeyring nova',
      'unless'  => 'groups nova | grep cephkeyring'
    })

    ensure_resource('file', "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring", {
      owner   => 'root',
      group   => 'cephkeyring',
      mode    => '0440',
      require => Ceph::Key[$cinder_rbd_user],
    })

    Concat::Fragment <<| title == 'ceph-client-os' |>>
  } else {
    $libvirt_disk_cachemodes_real = []
  }

  class { 'nova::compute::libvirt':
    libvirt_type            => $libvirt_type,
    # Needed to support migration but we still use Spice:
    vncserver_listen        => '0.0.0.0',
    migration_support       => true,
    libvirt_disk_cachemodes => $libvirt_disk_cachemodes_real
  }

  # Extra config for nova-compute
  nova_config {
    'DEFAULT/libvirt_inject_key':        value => false;
    'DEFAULT/libvirt_inject_partition':  value => '-2';
    'DEFAULT/live_migration_flag':       value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST';
  }

  class { 'ceilometer::agent::compute': }

}
