#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
# Horizon dashboard
#

class os_dashboard(
  $ks_keystone_internal_host = $os_params::ks_keystone_internal_host,
  $secret_key                = $os_params::secret_key,
  $horizon_port              = $os_params::horizon_port,
  $local_ip                  = $ipaddress_eth0,
  $listen_ssl                = false,
) {

  class {'horizon':
    secret_key          => $secret_key,
    keystone_host       => $ks_keystone_internal_host,
    can_set_mount_point => 'False',
  }

  @@haproxy::balancermember{"${::fqdn}-horizon":
    listening_service => 'horizon_cluster',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $horizon_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
