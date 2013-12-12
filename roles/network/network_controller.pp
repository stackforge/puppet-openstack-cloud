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
# Network Controller node (API + Scheduler)
#

class os_network_controller(
  $ks_neutron_password     = os_params::ks_neutron_password,
  $ks_keystone_admin_host  = os_params::ks_keystone_admin_host,
  $ks_keystone_public_port = os_params::ks_keystone_public_port,
) {

  class { 'neutron::server':
    auth_password => $os_params::ks_neutron_password,
    auth_host     => $os_params::ks_keystone_admin_host,
    auth_port     => $os_params::ks_keystone_public_port
  }

  @@haproxy::balancermember{"${fqdn}-neutron_api":
    listening_service => "neutron_api_cluster",
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => '9696',
    options           => "check inter 2000 rise 2 fall 5"
  }

}
