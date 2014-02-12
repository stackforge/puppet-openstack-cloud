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

class cloud::volume::storage(
  $glance_api_version     = $os_params::glance_api_version,
  $cinder_rbd_pool        = $os_params::cinder_rbd_pool,
  $cinder_rbd_user        = $os_params::cinder_rbd_user,
  $ceph_fsid              = $os_params::ceph_fsid,
) {

  include 'cloud::volume'

  include 'cinder::volume'

  class { 'cinder::volume::rbd':
    rbd_pool           => $cinder_rbd_pool,
    glance_api_version => $glance_api_version,
    rbd_user           => $cinder_rbd_user,
    rbd_secret_uuid    => $ceph_fsid
  }

  Ceph::Key <<| title == $cinder_user |>>
  if defined(Ceph::Key[$cinder_user]) {
    file { '/etc/ceph/ceph.client.cinder.keyring':
      owner   => 'cinder',
      group   => 'cinder',
      mode    => '0400',
      require => Ceph::Key[$cinder_user]
    }
  }
  Concat::Fragment <<| title == 'ceph-client-os' |>>

}
