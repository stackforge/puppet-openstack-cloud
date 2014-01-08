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
class privatecloud::storage::rbd::osd (
  $public_address  = $::ipaddress_eth0,
  $cluster_address = $::ipaddress_eth0,
  $devices         = ['sdb','sdc'],
) {

  include 'privatecloud::storage::rbd'

  class { 'ceph::osd' :
    public_address  => $public_address,
    cluster_address => $cluster_address,
  }

  $osd_ceph = prefix($devices,'/dev/')
  ceph::osd::device { $osd_ceph: }

}
