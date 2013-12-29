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

class privatecloud::rbd (
  $fsid,
  $auth_type = 'cephx',
  $release = 'cuttlefish'
) {

  class { 'ceph::conf':
    fsid            => $os_params::ceph_fsid,
    auth_type       => $auth_type,
    cluster_network => $os_params::ceph_cluster_network,
    public_network  => $os_params::ceph_public_network,
  }

  class { ceph::apt::ceph:
    release => $release
  }

}

# Monitor node
class role_ceph_mon (
  $id
) {

  class { 'role_ceph':
    fsid           => $os_params::ceph_fsid,
    auth_type      => 'cephx',
  }

  ceph::mon { $id:
    monitor_secret => $os_params::ceph_mon_secret,
    mon_port       => 6789,
    mon_addr       => $ipaddress_eth2,
  }
}

define ceph_osd_journal (
  $ceph_osd_device = $name
) {

  $osd_id_fact = "ceph_osd_id_${ceph_osd_device}1"
  $osd_id = inline_template("<%= scope.lookupvar(osd_id_fact) or 'undefined' %>")

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
