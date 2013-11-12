#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Sebastien Badia <sebastien.badia@enovance.com>
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
# Heat server
#
class os_role_heat {
  class { 'heat':
    $keystone_host => $os_params::ks_keystone_public_host,
    $keystone_port => $os_params::ks_keystone_public_port,
    $keystone_protocol => $os_params::ks_keystone_public_proto,
    $keystone_password => $os_params::ks_heat_password,
  }

  class { 'heat::api': }

} # Class:: os_role_heat
