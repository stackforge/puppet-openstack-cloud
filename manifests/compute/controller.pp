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
# Compute controller node
#

class privatecloud::compute::controller(
  $ks_keystone_internal_host            = $os_params::ks_keystone_internal_host,
  $ks_nova_password                     = $os_params::ks_nova_password,
  $neutron_metadata_proxy_shared_secret = $os_params::neutron_metadata_proxy_shared_secret,
  $api_eth                              = $os_params::api_eth,
  $spice_port                           = $os_params::spice_port,
  $ks_nova_public_port                  = $os_params::ks_nova_public_port,
  $ks_ec2_public_port                   = $os_params::ks_ec2_public_port,
  $ks_metadata_public_port              = $os_params::ks_metadata_public_port
){

  include 'privatecloud::compute'

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor',
    # TODO(Emilien) Migrate to spice asap
    #'nova::spicehtml5proxy',
    'nova::vncproxy',
  ]:
    enabled => true,
  }

    class { 'nova::api':
      enabled                              => true,
      auth_host                            => $ks_keystone_internal_host,
      admin_password                       => $ks_nova_password,
      api_bind_address                     => $api_eth,
      neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_shared_secret,
    }

  @@haproxy::balancermember{"${::fqdn}-compute_api_ec2":
    listening_service => 'ec2_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_ec2_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-compute_api_nova":
    listening_service => 'nova_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_nova_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-compute_api_metadata":
    listening_service => 'metadata_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_metadata_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-compute_spice":
    listening_service => 'spice_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $spice_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
