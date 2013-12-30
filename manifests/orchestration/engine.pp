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
# Orchestration engine node (should be run once)
# Could be managed by spof node as Active / Passive.
#

class privatecloud::orchestration::engine(
  $enabled                    = true,
  $ks_heat_public_host        = $os_params::ks_heat_public_host,
  $ks_heat_public_proto       = $os_params::ks_heat_public_proto,
  $ks_heat_password           = $os_params::ks_heat_password,
) {

  include 'privatecloud::orchestration'

  class { 'heat::engine':
    enabled                       => $enabled,
    heat_metadata_server_url      => "${ks_heat_public_proto}://${ks_heat_public_host}:8000",
    heat_waitcondition_server_url => "${ks_heat_public_proto}://${ks_heat_public_host}:8000/v1/waitcondition",
    heat_watch_server_url         => "${ks_heat_public_proto}://${ks_heat_public_host}:8003"
  }

}
