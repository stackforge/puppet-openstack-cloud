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
# == Class: cloud::logging::server
#
# [*kibana_port*]
#   (optional) Port of Kibana service.
#   Defaults to '8300'
#
# [*kibana_bind_ip*]
#   (optional) Address on which kibana is listening on
#   Defaults to '127.0.0.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::logging::server(
  $kibana_port           = '8300',
  $kibana_bind_ip        = '127.0.0.1',
  $firewall_settings     = {},
) {

  Class['cloud::database::nosql::elasticsearch'] -> Class['kibana3']
  Class['cloud::database::nosql::elasticsearch'] -> Class['cloud::logging::agent']

  include ::kibana3
  include cloud::database::nosql::elasticsearch
  include cloud::logging::agent

  # Elasticsearch 1.4 ships with a security setting that prevents Kibana from connecting.
  # We need to allow http cors in fluentd instance.
  $config_hash = { 'http.cors.enabled' => true }
  elasticsearch::instance {'fluentd' :
    config => $config_hash,
  }

  @@haproxy::balancermember{"${::fqdn}-kibana":
    listening_service => 'kibana',
    server_names      => $::hostname,
    ipaddresses       => $kibana_bind_ip,
    ports             => $kibana_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow kibana access':
      port   => $kibana_port,
      extras => $firewall_settings,
    }
  }

}
