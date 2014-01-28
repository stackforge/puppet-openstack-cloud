#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
class cloud::storage::rbd::pools(
  $setup_pools          = false,
  $glance_user          = $os_params::glance_rbd_user,
  $glance_pool          = $os_params::glance_rbd_pool,
  $cinder_user          = $os_params::cinder_rbd_user,
  $cinder_pool          = $os_params::cinder_rbd_pool,
  $pool_default_pg_num  = $::ceph::conf::pool_default_pg_num,
  $pool_default_pgp_num = $::ceph::conf::pool_default_pgp_num,
  $cinder_backup_user   = $os_params::cinder_rbd_backup_user,
  $cinder_backup_pool   = $os_params::cinder_rbd_backup_pool,
  $ceph_fsid            = $os_params::ceph_fsid,
) {

  if $setup_pools {

    if !empty($::ceph_admin_key) {
      # ceph osd pool create poolname 128 128
      exec { 'create_glance_images_pool':
        command => "rados mkpool ${glance_pool} ${pool_default_pg_num} ${pool_default_pgp_num}",
        unless  => "rados lspools | grep -sq ${glance_pool}",
      }

      exec { 'create_glance_images_user_and_key':
        command => "ceph auth get-or-create client.${glance_user} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${glance_pool}'",
        unless  => "ceph auth list 2> /dev/null | egrep -sq '^client.${glance_user}$'",
        require => Exec['create_glance_images_pool'];
      }

      # ceph osd pool create poolname 128 128
      exec { 'create_cinder_volumes_pool':
        command => "rados mkpool ${cinder_pool} ${pool_default_pg_num} ${pool_default_pgp_num}",
        unless  => "/usr/bin/rados lspools | grep -sq ${cinder_pool}",
      }

      exec { 'create_cinder_volumes_user_and_key':
        # TODO: point PG num with a cluster variable
        command => "ceph auth get-or-create client.${cinder_user} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${glance_pool}, allow rx pool=${cinder_pool}'",
        unless  => "ceph auth list 2> /dev/null | egrep -sq '^client.${cinder_user}$'",
        require => Exec['create_cinder_volumes_pool'];
      }
    } # !empty($::ceph_admin_key)

#    exec { "create cinder backup pool":
#      # TODO: point PG num with a cluster variable + keyring
#      command => "/usr/bin/ceph osd pool create ${::cinder_backup_pool} 128 128",
#      command => "\
#ceph auth get-or-create client.${::cinder_backup_user} mon 'allow r' \
#osd 'allow class-read object_prefix rbd_children, allow rwx pool=${::cinder_backup_pool}'",
#      unless => "/usr/bin/rados lspools | grep -sq ${::cinder_backup_pool}",
#      unless  => "ceph auth list | egrep '^${::cinder_backup_pool}$'",
#      require => Ceph::Key['admin'],
#    }

    @@file { '/etc/ceph/secret.xml':
      content => template('cloud/storage/ceph/secret-compute.xml.erb'),
      tag     => 'ceph_compute_secret_file',
    }

    @@exec { 'get_or_set_virsh_secret':
      command => 'virsh secret-define --file /etc/ceph/secret.xml',
      unless  => "virsh secret-list | tail -n +3 | cut -f1 -d' ' | grep -sq ${ceph_fsid}",
      tag     => 'ceph_compute_get_secret',
      require => [Package['libvirt-bin'],File['/etc/ceph/secret.xml']],
      notify  => Exec['set_secret_value_virsh'],
    }

    @@exec { 'set_secret_value_virsh':
      command      => "virsh secret-set-value --secret ${ceph_fsid} --base64 ${::ceph_keyring_glance}",
      tag          => 'ceph_compute_set_secret',
      refreshonly  =>  true,
    }

  } # if setup pools
} # class
