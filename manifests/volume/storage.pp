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
# Volume storage
#
# === Parameters
#
# [*cinder_rbd_pool*]
#   (optional) Specifies the pool name for the block device driver.
#
# [*glance_api_version*]
#   (optional) Required for Ceph functionality.
#
# [*cinder_rbd_user*]
#   (optional) A required parameter to configure OS init scripts and cephx.
#
# [*cinder_rbd_secret_uuid*]
#   (optional) A required parameter to use cephx.
#
# [*cinder_rbd_conf*]
#   (optional) Path to the ceph configuration file to use
#   Defaults to '/etc/ceph/ceph.conf'
#
# [*cinder_rbd_flatten_volume_from_snapshot*]
#   (optional) Enalbe flatten volumes created from snapshots.
#   Defaults to false
#
# [*cinder_volume_tmp_dir*]
#   (optional) Location to store temporary image files if the volume
#   driver does not write them directly to the volume
#   Defaults to false
#
# [*cinder_rbd_max_clone_depth*]
#   (optional) Maximum number of nested clones that can be taken of a
#   volume before enforcing a flatten prior to next clone.
#   A value of zero disables cloning
#   Defaults to '5'
#
#
class cloud::volume::storage(
  $glance_api_version                      = $os_params::glance_api_version,
  $cinder_rbd_pool                         = $os_params::cinder_rbd_pool,
  $cinder_rbd_user                         = $os_params::cinder_rbd_user,
  $cinder_rbd_secret_uuid                  = $os_params::ceph_fsid,
  $cinder_rbd_conf                         = '/etc/ceph/ceph.conf',
  $cinder_rbd_flatten_volume_from_snapshot = false,
  $cinder_rbd_max_clone_depth              = '5',
) {

  include 'cloud::volume'

  include 'cinder::volume'

  class { 'cinder::volume::rbd':
    rbd_pool                         => $cinder_rbd_pool,
    glance_api_version               => $glance_api_version,
    rbd_user                         => $cinder_rbd_user,
    rbd_secret_uuid                  => $cinder_rbd_secret_uuid,
    rbd_ceph_conf                    => $cinder_rbd_conf,
    rbd_flatten_volume_from_snapshot => $cinder_rbd_flatten_volume_from_snapshot,
    rbd_max_clone_depth              => $cinder_rbd_max_clone_depth,
  }

  Ceph::Key <<| title == $cinder_rbd_user |>>
  if defined(Ceph::Key[$cinder_rbd_user]) {
    file { "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring":
      owner   => 'cinder',
      group   => 'cinder',
      mode    => '0400',
      require => Ceph::Key[$cinder_rbd_user]
    }
  }
  Concat::Fragment <<| title == 'ceph-client-os' |>>

}
