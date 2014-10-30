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
# Orchestration engine node (should be run once)
# Could be managed by spof node as Active / Passive.
#
class cloud::orchestration::engine(
  $enabled                        = true,
  $ks_heat_public_host            = '127.0.0.1',
  $ks_heat_public_proto           = 'http',
  $ks_heat_password               = 'heatpassword',
  $ks_heat_cfn_public_port        = 8000,
  $ks_heat_cloudwatch_public_port = 8003,
  $auth_encryption_key            = 'secrete',
  $ks_admin_tenant                = 'admin',
) {

  include 'cloud::orchestration'

  class { 'heat::engine':
    enabled                       => $enabled,
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cfn_public_port}",
    heat_waitcondition_server_url => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cfn_public_port}/v1/waitcondition",
    heat_watch_server_url         => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cloudwatch_public_port}"
  }

  # to avoid bug https://bugs.launchpad.net/heat/+bug/1306665
  keystone_user_role { "admin@${ks_admin_tenant}":
    ensure => present,
    roles  => 'heat_stack_owner',
  }

}
