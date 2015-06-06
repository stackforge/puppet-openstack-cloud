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
# == Class: cloud::network::contrail::haproxy
#
# Create the haproxy stanzas for Contrail related services
#
# === Parameters:
#
# [*contrail_analytics_api*]
#   (optional) Enable or not Contrail analytics api public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to false
#
# [*contrail_config_api*]
#   (optional) Enable or not Contrail config api binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*contrail_config_discovery*]
#   (optional) Enable or not Contrail discoverybinding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*contrail_webui_http*]
#   (optional) Enable or not Contrail webui http binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*contrail_webui_https*]
#   (optional) Enable or not Contrail webui https binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*contrail_analytics_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*contrail_config_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*contrail_config_discovery_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*contrail_webui_http_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*contrail_webui_https_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*contrail_analytics_api_port*]
#   (optional) TCP port to connect to Contrail analytics api from public network
#   Defaults to '8081'
#
# [*contrail_config_api_port*]
#   (optional) TCP port to connect to Contrail config api from public network
#   Defaults to '8082'
#
# [*contrail_config_discovery*]
#   (optional) TCP port to connect to Contrail discovery from public network
#   Defaults to '5998'
#
# [*contrail_webui_http*]
#   (optional) TCP port to connect to Contrail webui http from public network
#   Defaults to '8079'
#
# [*contrail_webui_https*]
#   (optional) TCP port to connect to Contrail webui https from public network
#   Defaults to '8143'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::contrail::haproxy (
  $contrail_analytics_api                 = false,
  $contrail_config_api                    = false,
  $contrail_config_discovery              = false,
  $contrail_webui_http                    = false,
  $contrail_webui_https                   = false,
  $contrail_analytics_api_bind_options    = [],
  $contrail_config_api_bind_options       = [],
  $contrail_config_discovery_bind_options = [],
  $contrail_webui_http_bind_options       = [],
  $contrail_webui_https_bind_options      = [],
  $contrail_analytics_api_port            = 8081,
  $contrail_config_api_port               = 8082,
  $contrail_config_discovery_port         = 5998,
  $contrail_webui_http_port               = 8079,
  $contrail_webui_https_port              = 8143,
  $firewall_settings                      = {},
){

  cloud::loadbalancer::binding { 'contrail_analytics_api':
    ip                => $contrail_analytics_api,
    port              => $contrail_analytics_api_port,
    bind_options      => $contrail_analytics_api_bind_options,
    firewall_settings => $firewall_settings,
    options           => {
      'balance'        => 'roundrobin',
      'option'         => ['nolinger', 'tcp-check'],
      'default-server' => 'error-limit 1 on-error mark-down',
    },
  }

  cloud::loadbalancer::binding { 'contrail_config_api':
    ip                => $contrail_config_api,
    port              => $contrail_config_api_port,
    bind_options      => $contrail_config_api_bind_options,
    firewall_settings => $firewall_settings,
    options           => {
      'balance'        => 'roundrobin',
      'option'         => ['nolinger'],
    },
  }

  cloud::loadbalancer::binding { 'contrail_config_discovery':
    ip                => $contrail_config_discovery,
    port              => $contrail_config_discovery_port,
    bind_options      => $contrail_config_discovery_bind_options,
    firewall_settings => $firewall_settings,
    options           => {
      'balance'        => 'roundrobin',
      'option'         => ['nolinger'],
    },
  }

  cloud::loadbalancer::binding { 'contrail_webui_http':
    ip                => $contrail_webui_http,
    port              => $contrail_webui_http_port,
    bind_options      => $contrail_webui_http_bind_options,
    firewall_settings => $firewall_settings,
  }

  cloud::loadbalancer::binding { 'contrail_webui_https':
    ip                => $contrail_webui_https,
    port              => $contrail_webui_https_port,
    bind_options      => $contrail_webui_https_bind_options,
    httpchk           => 'ssl-hello-chk',
    firewall_settings => $firewall_settings,
    options           => {
      'mode'    => 'tcp',
      'cookie'  => 'sessionid prefix',
      'balance' => 'leastconn'
      'reqadd'  => 'X-Forwarded-Proto:\ https if { ssl_fc }',
    }
  }

}
