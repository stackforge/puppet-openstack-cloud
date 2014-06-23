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
# Volume controller
#

class cloud::volume::controller(
  $ks_cinder_internal_port     = 8776,
  $ks_cinder_password          = 'cinderpassword',
  $ks_keystone_internal_host   = '127.0.0.1',
  $ks_keystone_internal_proto  = 'http',
  $ks_glance_internal_host     = '127.0.0.1',
  $ks_glance_api_internal_port = 9292,
  $api_eth                     = '127.0.0.1',
  $default_volume_type         = undef,
  # Maintain backward compatibility for multi-backend
  $volume_multi_backend        = false
) {

  warning('This class is deprecated. You should use cloud::volume::api,backup,scheduler.')

  include 'cloud::volume'

  # Maintain backward compatibility
  class { 'cloud::volume::api':
    ks_cinder_internal_port     => $ks_cinder_internal_port,
    ks_cinder_password          => $ks_cinder_password,
    ks_keystone_internal_host   => $ks_keystone_internal_host,
    ks_keystone_internal_proto  => $ks_keystone_internal_proto,
    ks_glance_internal_host     => $ks_glance_internal_host,
    ks_glance_api_internal_port => $ks_glance_api_internal_port,
    api_eth                     => $api_eth,
    default_volume_type         => $default_volume_type,
    # Maintain backward compatibility for multi-backend
    volume_multi_backend        => $volume_multi_backend
  }
  class { 'cloud::volume::scheduler':
    volume_multi_backend => $volume_multi_backend
  }

  class { 'cloud::volume::backup': }

}
