#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
#

define privatecloud::rbd::journal (
  $ceph_osd_device = $name
) {

  $osd_id_fact = "ceph_osd_id_${ceph_osd_device}1"
  # NOTE(EmilienM) I've change double quotes to simple qotes, not sure though:
  $osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) or 'undefined' %>')

  if $osd_id != 'undefined' {
    $osd_data = regsubst($::ceph::conf::osd_data, '\$id', $osd_id)

    file { "${osd_data}/journal":
      ensure  => link,
      target  => "/dev/mapper/rootfs-journal--${ceph_osd_device}1",
      owner   => 'root',
      group   => 'root',
      mode    => '0660',
      require => Mount[$osd_data],
      before  => Service["ceph-osd.${osd_id}"]
    }
  }

}
