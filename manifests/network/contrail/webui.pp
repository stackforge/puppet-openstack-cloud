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
# == Class: cloud::network::contrail::webui
#
# Install a Contrail webui node
#
# === Parameters:
#
# [*http_bind_ip*]
#   (optional) Address on which the Contrail webui http service is listening on
#   Defaults to '127.0.0.1'
#
# [*https_bind_ip*]
#   (optional) Address on which the Contrail webui https service is listening on
#   Defaults to '127.0.0.1'
#
# [*http_port*]
#   (optional) Port where Contrail webui http service is bound to
#   Used for firewall purpose.
#   Default to 9100
#
# [*https_port*]
#   (optional) Port where Contrail webui https is bound to
#   Used for firewall purpose.
#   Default to 9110
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::contrail::webui (
  $http_bind_ip      = '127.0.0.1',
  $https_bind_ip     = '127.0.0.1',
  $http_port         = 8080,
  $https_port        = 8143,
  $firewall_settings = {},
  $firewall_settings = {},
){

  include ::contrail::webui

  @@haproxy::balancermember{"${::fqdn}-contrail-webui-http":
    listening_service => 'contrail_webui_http',
    server_names      => $::hostname,
    ipaddresses       => $http_bind_ip,
    ports             => $http_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-contrail-webui-https":
    listening_service => 'contrail_webui_https',
    server_names      => $::hostname,
    ipaddresses       => $https_bind_ip,
    ports             => $https_port,
    options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow contrail webui access':
      port   => ['8080', '8143'],
      extras => $firewall_settings,
    }
  }

}
