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
# [*volume_multi_backend*]
#   (optionnal) To maintain backward compatibility with previous versions of this module,
#   this parameter aims to enable or not the multi-backend feature.
#   Defaults to false
#
# [*rbd_backend*]
#   (optionnal) Use RBD backend or not.
#   Defaults to true
#
# [*rbd_backend_name*]
#   (optionnal) Backend name presented to end-user.
#   Defaults to 'rbd'
#
# [*cinder_rbd_pool*]
#   (optional) Specifies the pool name for the block device driver.
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
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Default to '5000'
#
# [*ks_cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Defaults to 'secrete'
#
# [*netapp_backend*]
#   (optionnal) Use NetApp backend or not.
#   Defaults to false
#
# [*netapp_backend_name*]
#   (optionnal) Backend name presented to end-user.
#   Defaults to 'rbd'
#
# [*netapp_login*]
#   (optionnal) Administrative user account name used to access the storage
#   system.
#   Defaults to 'netapp'
#
# [*netapp_password*]
#   (optionnal) Password for the administrative user account specified in the
#   netapp_login parameter.
#   Defaults to 'secrete'
#
# [*netapp_server_hostname*]
#   (optionnal) The hostname (or IP address) for the storage system.
#   Defaults to '127.0.0.1'
#


class cloud::volume::storage(
  # Maintain backward compatibility
  $volume_multi_backend                    = false,
  $cinder_rbd_pool                         = $os_params::cinder_rbd_pool,
  $cinder_rbd_user                         = $os_params::cinder_rbd_user,
  $cinder_rbd_secret_uuid                  = $os_params::ceph_fsid,
  # RBD is our reference backend by default.
  $rbd_backend                             = true,
  $rbd_backend_name                        = 'rbd',
  $ks_keystone_internal_proto              = 'http',
  $ks_keystone_internal_port               = '5000',
  $ks_keystone_internal_host               = '127.0.0.1',
  $ks_cinder_password                      = 'secrete',
  # NetApp stays an option by default.
  $netapp_backend                          = false,
  $netapp_backend_name                     = 'netapp',
  $netapp_server_hostname                  = '127.0.0.1',
  $netapp_login                            = 'netapp',
  $netapp_password                         = 'secrete',
  # Deprecated parameters
  $glance_api_version                      = '2',
  $cinder_rbd_conf                         = '/etc/ceph/ceph.conf',
  $cinder_rbd_flatten_volume_from_snapshot = false,
  $cinder_rbd_max_clone_depth              = '5'
) {

  include 'cloud::volume'

  include 'cinder::volume'

  if $volume_multi_backend {
    # Manage Volume types.
    # It allows to the end-user to choose from which backend he would like to provision a volume.
    # Cinder::Type requires keystone credentials
    Cinder::Type {
      os_tenant_name => 'services',
      os_username    => 'cinder',
      os_password    => $ks_cinder_password,
      os_auth_url    => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0"
    }

    if $rbd_backend {
      # Configure RBD as a backend
      cinder::backend::rbd {"${rbd_backend_name}":
        rbd_pool         => $cinder_rbd_pool,
        rbd_user         => $cinder_rbd_user,
        rbd_secret_uuid  => $cinder_rbd_secret_uuid
      }

      # Configure a specific Volume Type
      cinder::type {'rbd':
        set_key   => 'volume_backend_name',
        set_value => $rbd_backend_name
      }

      # Configure Ceph keyring
      Ceph::Key <<| title == $cinder_rbd_user |>>
      file { "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring":
        owner   => 'cinder',
        group   => 'cinder',
        mode    => '0400',
        require => Ceph::Key[$cinder_rbd_user]
      }
      Concat::Fragment <<| title == 'ceph-client-os' |>>
    }

    if $netapp_backend {
      # Configure NetApp as a backend
      cinder::backend::netapp {"${netapp_backend_name}":
        netapp_server_hostname => $netapp_server_hostname,
        netapp_login           => $netapp_login,
        netapp_password        => $netapp_password
      }

      # Configure a specific Volume Type
      cinder::type {'netapp':
        set_key   => 'volume_backend_name',
        set_value => $netapp_backend_name
      }
    }

    # TODO(EmilienM) need to be optimized:
    if $netapp_backend and $rbd_backend {
      $enabled_backends = ['netapp', 'rbd']
    } elsif $netapp_backend and ! $rbd_backend {
      $enabled_backends = ['netapp']
    } elsif ! $netapp_backend and $rbd_backend {
      $enabled_backends = ['rbd']
    } else {
      fail('no cinder backend has been enabled on storage nodes.')
    }
    class {'cinder::backends': enabled_backends => $enabled_backends }
  } else {
    # Backward compatibility
    class { 'cinder::volume::rbd':
      rbd_pool                         => $cinder_rbd_pool,
      glance_api_version               => $glance_api_version,
      rbd_user                         => $cinder_rbd_user,
      rbd_secret_uuid                  => $cinder_rbd_secret_uuid,
      rbd_ceph_conf                    => $cinder_rbd_conf,
      rbd_flatten_volume_from_snapshot => $cinder_rbd_flatten_volume_from_snapshot,
      rbd_max_clone_depth              => $cinder_rbd_max_clone_depth
    }
    Ceph::Key <<| title == $cinder_rbd_user |>>
    file { "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring":
      owner   => 'cinder',
      group   => 'cinder',
      mode    => '0400',
      require => Ceph::Key[$cinder_rbd_user]
    }
    Concat::Fragment <<| title == 'ceph-client-os' |>>
  }

}
