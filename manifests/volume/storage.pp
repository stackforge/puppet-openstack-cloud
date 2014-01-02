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
# Volume storage
#

class privatecloud::volume::storage {

  include 'privatecloud::volume'

  class { 'cinder::volume::rbd':
    rbd_pool           => $os_params::cinder_rbd_pool,
    glance_api_version => $os_params::glance_api_version,
    rbd_user           => $os_params::cinder_rbd_user,
    rbd_secret_uuid    => $os_params::cinder_rbd_secret_uuid
  }

}
