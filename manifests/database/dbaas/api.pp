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
# == Class: cloud::database::dbaas::api
#
# Class to install API service of OpenStack Database as a Service (Trove)
#

class cloud::database::dbaas::api(
  $ks_trove_password          = 'trovepassword',
  $verbose                    = true,
  $debug                      = true,
  $use_syslog                 = true,
  $api_eth                    = '127.0.0.1',
  $ks_trove_public_port       = '8779',
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
) {

  include 'cloud::database::dbaas'

  class { 'trove::api':
    verbose           => $verbose,
    debug             => $debug,
    use_syslog        => $use_syslog,
    bind_host         => $api_eth,
    bind_port         => $ks_trove_public_port,
    auth_url          => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    keystone_password => $ks_trove_password,
  }

  @@haproxy::balancermember{"${::fqdn}-trove_api":
    listening_service => 'trove_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_trove_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
