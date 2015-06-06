#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::network::contrail::config
#
# Install a Contrail config node
#
# === Parameters:
#
# [*api_bind_ip*]
#   (optional) Address on which the Contrail config api is listening on
#   Defaults to '127.0.0.1'
#
# [*discovery_bind_ip*]
#   (optional) Address on which the Contrail discovery is listening on
#   Defaults to '127.0.0.1'
#
# [*api_port*]
#   (optional) Port where Contrail config api is bound to
#   Used for firewall purpose.
#   Default to 9100
#
# [*discovery_port*]
#   (optional) Port where Contrail discovery is bound to
#   Used for firewall purpose.
#   Default to 9110
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::contrail::config (
  $api_bind_ip       = '127.0.0.1',
  $discovery_bind_ip = '127.0.0.1',
  $api_port          = 9100,
  $discovery_port    = 9110,
  $firewall_settings = {},
){

  include ::contrail::config

  @@haproxy::balancermember{"${::fqdn}-contrail-config-api":
    listening_service => 'contrail_config_api',
    server_names      => $::hostname,
    ipaddresses       => $api_bind_ip,
    ports             => $api_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-contrail-config-discovery":
    listening_service => 'contrail_config_discovery',
    server_names      => $::hostname,
    ipaddresses       => $api_bind_ip,
    ports             => $api_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow contrail config access':
      port   => ['8443', '8087', '8088', $discovery_port, $api_port],
      extras => $firewall_settings,
    }
  }

}
