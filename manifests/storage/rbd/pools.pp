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
# Class:: privatecloud::storage::pools()
#
#
class privatecloud::storage::rbd::pools(
  $setup_pools        = false,
  $glance_pool        = 'ceph_glance',
  $glance_user        = 'glance',
  $cinder_pool        = 'ceph_cinder',
  $cinder_user        = 'cinder',
  $cinder_backup_user = 'cinder',
  $cinder_backup_pool = 'ceph_backup_cinder') {

  if $setup_pools {

    exec { 'create_glance_images_pool':
      # TODO: point PG num with a cluster variable + keyring
      command => "ceph osd pool create ${::glance_pool} 128 128",
      unless  => "rados lspools | grep -sq ${::glance_pool}",
      require => Ceph::Key['admin'];
    }

    exec { 'create_glance_images_user_and_key':
      # TODO: point PG num with a cluster variable + keyring
      command => "\
ceph auth get-or-create client.${::glance_user} mon 'allow r' \
osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'",
      unless  => "ceph auth list | egrep '^${::glance_pool}$'",
      require => Exec['create_glance_images_pool'];
    }


    exec { 'create_cinder_volumes_pool':
      # TODO: point PG num with a cluster variable + keyring
      command => "/usr/bin/ceph osd pool create ${::cinder_pool} 128 128",
      unless  => "/usr/bin/rados lspools | grep -sq ${::cinder_pool}",
      require => Ceph::Key['admin'];
    }

    exec { 'create_cinder_volumes_user_and_key':
      # TODO: point PG num with a cluster variable + keyring
      command => "ceph auth get-or-create client.${::cinder_user} mon 'allow r' \
osd 'allow class-read object_prefix rbd_children, allow rwx pool=${::glance_pool}, allow rx pool=${::cinder_pool}'",
      unless  => "ceph auth list | egrep '^${::cinder_pool}$'",
      require => Exec['create_cinder_volumes_pool'];
    }

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
  }

}
