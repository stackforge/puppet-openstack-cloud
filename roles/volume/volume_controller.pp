#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
#          Sebastien Badia <sebastien.badia@enovance.com>
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
# Volume controller

class os_volume_controller(
  $ks_cinder_password        = $os_params::ks_cinder_password,
  $ks_keystone_internal_host = $os_params::ks_keystone_internal_host,
) {

  class { 'cinder::scheduler': }

  class { 'cinder::api':
    keystone_password      => $os_params::ks_cinder_password,
    keystone_auth_host     => $os_params::ks_keystone_internal_host,
  }

}
