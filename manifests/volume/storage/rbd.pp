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
# Volume Ceph storage
#

define cloud::volume::storage::rbd (
  $volume_backend_name = $name,
  $rbd_pool,
  $glance_api_version,
  $rbd_user,
  $rbd_secret_uuid,
  $rbd_ceph_conf,
  $rbd_flatten_volume_from_snapshot,
  $rbd_max_clone_depth,
) {

  cinder::backend::rbd { $volume_backend_name:
    rbd_pool                         => $rbd_pool,
    glance_api_version               => $glance_api_version,
    rbd_user                         => $rbd_user,
    rbd_secret_uuid                  => $rbd_secret_uuid,
    rbd_ceph_conf                    => $rbd_ceph_conf,
    rbd_flatten_volume_from_snapshot => $rbd_flatten_volume_from_snapshot,
    rbd_max_clone_depth              => $rbd_max_clone_depth,
  }

 # Configure Ceph keyring
  Ceph::Key <<| title == $rbd_user |>>
  file { "/etc/ceph/ceph.client.${rbd_user}.keyring":
    owner   => 'cinder',
    group   => 'cinder',
    mode    => '0400',
    require => Ceph::Key[$rbd_user]
  }
  Concat::Fragment <<| title == 'ceph-client-os' |>>

  @cinder::type { $volume_backend_name:
    set_key   => 'volume_backend_name',
    set_value => $volume_backend_name
  }
}
