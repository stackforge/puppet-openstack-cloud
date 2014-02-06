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

class cloud::storage::rbd::monitor (
  $id             = $::uniqueid,
  $mon_addr       = $os_params::api_eth,
  $monitor_secret = $os_params::ceph_mon_secret
) {

  include 'cloud::storage::rbd'

  ceph::mon { $id:
    monitor_secret => $monitor_secret,
    mon_port       => 6789,
    mon_addr       => $mon_addr,
  }

}
