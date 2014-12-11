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
# == Class: cloud::storage::rbd::clients
#
# Configure Ceph RBD clients
#
# === Parameters:
#
# [*glance_rbd_user*]
#   (optional) User name used to acces to the glance rbd pool
#   Defaults to 'glance'
#
# [*cinder_backup_user*]
#   (optional) User name used to acces to the backup rbd pool
#   Defaults to 'cinder'
#
# [*cinder_rbd_user*]
#   (optional) User name used to acces to the cinder rbd pool
#   Defaults to 'cinder'
#
class cloud::storage::rbd::clients (
  $glance_rbd_user    = 'glance',
  $cinder_rbd_user    = 'cinder',
  $cinder_backup_user = 'cinder'
) {
      if $::ceph_keyring_glance {
        # NOTE(fc): Puppet needs to run a second time to enter this
        @@ceph::key { $glance_rbd_user:
          secret       => $::ceph_keyring_glance,
          keyring_path => "/etc/ceph/ceph.client.${glance_rbd_user}.keyring"
        }
        Ceph::Key <<| title == $glance_rbd_user |>>
      }

      if $::ceph_keyring_cinder {
        # NOTE(fc): Puppet needs to run a second time to enter this
        @@ceph::key { $cinder_rbd_user:
          secret       => $::ceph_keyring_cinder,
          keyring_path => "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring"
        }
        Ceph::Key <<| title == $cinder_rbd_user |>>
      }

      $clients = [$glance_rbd_user, $cinder_rbd_user]
      @@concat::fragment { 'ceph-clients-os':
        target  => '/etc/ceph/ceph.conf',
        order   => '95',
        content => template('cloud/storage/ceph/ceph-client.conf.erb')
      }
}
