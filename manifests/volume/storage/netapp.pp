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
# Volume Ceph storage
#

define cloud::volume::storage::netapp (
  $volume_backend_name                     = $name,
  $netapp_backend                          = false,
  $netapp_server_hostname                  = '127.0.0.1',
  $netapp_login                            = 'netapp',
  $netapp_password                         = 'secrete',
) {

  cinder::backend::netapp { $name:
    netapp_server_hostname => $netapp_server_hostname,
    netapp_login           => $netapp_login,
    netapp_password        => $netapp_password,
  }

  @cinder::type { $volume_backend_name:
    set_key   => 'volume_backend_name',
    set_value => $volume_backend_name
  }
}
