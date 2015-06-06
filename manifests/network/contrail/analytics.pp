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
# == Class: cloud::network::contrail::analytics
#
# Install a Contrail analytics node
#
# === Parameters:
#
# [*bind_ip*]
#   (optional) Address on which the Contrail analytics api is listening on
#   Defaults to '127.0.0.1'
#
# [*port*]
#   (optional) Port where Contrail analytics api is bound to
#   Used for firewall purpose.
#   Default to 8081
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::contrail::analytics (
  $bind_ip           = '127.0.0.1',
  $port              = 8081,
  $firewall_settings = {},
){

  include ::contrail::analytics

  @@haproxy::balancermember{"${::fqdn}-contrail-analytics-api":
    listening_service => 'contrail_analytics_api',
    server_names      => $::hostname,
    ipaddresses       => $bind_ip,
    ports             => $port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow contrail analytics access':
      port   => [$port, '8086'],
      extras => $firewall_settings,
    }
  }

}
