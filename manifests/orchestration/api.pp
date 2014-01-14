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
# Orchestration APIs node
#

class cloud::orchestration::api(
  $ks_heat_internal_port            = $os_params::ks_heat_internal_port,
  $ks_heat_cfn_internal_port        = $os_params::ks_heat_cfn_internal_port,
  $ks_heat_cloudwatch_internal_port = $os_params::ks_heat_cloudwatch_internal_port,
  $api_eth                          = $os_params::api_eth,
) {

  include 'cloud::orchestration'

  class { 'heat::api':
    bind_host => $api_eth,
    bind_port => $ks_heat_internal_port
  }

  class { 'heat::api_cfn':
    bind_host => $api_eth,
    bind_port => $ks_heat_cfn_internal_port
  }

  class { 'heat::api_cloudwatch':
    bind_host => $api_eth,
    bind_port => $ks_heat_cloudwatch_internal_port
  }

  @@haproxy::balancermember{"${::fqdn}-heat_api":
    listening_service => 'heat_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-heat_cfn_api":
    listening_service => 'heat_cfn_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_cfn_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-heat_cloudwatch_api":
    listening_service => 'heat_cloudwatch_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_cloudwatch_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
