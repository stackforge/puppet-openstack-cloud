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
# Volume API node
#

class cloud::volume::api(
  $ks_cinder_internal_port     = 8776,
  $ks_cinder_password          = 'cinderpassword',
  $ks_keystone_internal_host   = '127.0.0.1',
  $ks_glance_internal_host     = '127.0.0.1',
  $ks_glance_api_internal_port = 9292,
  $api_eth                     = '127.0.0.1',
  $default_volume_type         = undef,
  # Maintain backward compatibility for multi-backend
  $volume_multi_backend        = false
) {

  include 'cloud::volume'

  if ! $volume_multi_backend {
    $default_volume_type_real = undef
  } else {
    if ! $default_volume_type {
      fail('when using multi-backend, you should define a default_volume_type value in cloud::volume::controller')
    } else {
      $default_volume_type_real = $default_volume_type
    }
  }

  class { 'cinder::api':
    keystone_password   => $ks_cinder_password,
    keystone_auth_host  => $ks_keystone_internal_host,
    bind_host           => $api_eth,
    default_volume_type => $default_volume_type_real
  }

  class { 'cinder::glance':
    glance_api_servers     => "${ks_glance_internal_host}:${ks_glance_api_internal_port}",
    glance_request_timeout => '10'
  }

  @@haproxy::balancermember{"${::fqdn}-cinder_api":
    listening_service => 'cinder_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_cinder_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
