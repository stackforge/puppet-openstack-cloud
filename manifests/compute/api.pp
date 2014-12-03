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
# == Class: cloud::compute::api
#
# Install a Nova-API node
#
# === Parameters:
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*validation_settings*]
#   (optional) Service validation options
#   Should be a hash of options defined in openstacklib::service_validation
#   If empty, defaults values are taken from openstacklib function.
#   Default command list nova flavors.
#   Require validate set at True.
#   Example:
#   nova::api::validation_options:
#     nova-api:
#       command: check_nova.py
#       path: /usr/bin:/bin:/usr/sbin:/sbin
#       provider: shell
#       tries: 5
#       try_sleep: 10
#   Defaults to {}
#
class cloud::compute::api(
  $ks_keystone_internal_host            = '127.0.0.1',
  $ks_keystone_internal_proto           = 'http',
  $ks_nova_password                     = 'novapassword',
  $neutron_metadata_proxy_shared_secret = 'metadatapassword',
  $api_eth                              = '127.0.0.1',
  $ks_nova_public_port                  = '8774',
  $ks_ec2_public_port                   = '8773',
  $ks_metadata_public_port              = '8775',
  $firewall_settings                    = {},
  $validation_settings                  = {},
){

  include 'cloud::compute'

  $validation = pick($::cloud::validate_services, false)

  class { 'nova::api':
    enabled                              => true,
    auth_host                            => $ks_keystone_internal_host,
    auth_protocol                        => $ks_keystone_internal_proto,
    admin_password                       => $ks_nova_password,
    api_bind_address                     => $api_eth,
    metadata_listen                      => $api_eth,
    neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_shared_secret,
    osapi_v3                             => true,
    validate                             => $validation,
    validation_settings                  => $validation_settings,
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow nova-api access':
      port   => $ks_nova_public_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow nova-metadata access':
      port   => $ks_metadata_public_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow nova-ec2 access':
      port   => $ks_ec2_public_port,
      extras => $firewall_settings,
    }
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
}
