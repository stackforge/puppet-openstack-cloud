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
# == Class: cloud::storage::rbd
#
# === Parameters:
#
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*cluster_network*]
#   (optional) The cluster internal network
#   Defaults to '127.0.0.1/24'
#
# [*public_network*]
#   (optional) The cluster public (where clients are) network
#   Defaults to '127.0.0.1/24'
#
class cloud::storage::rbd (
  $fsid            = undef,
  $cluster_network = '127.0.0.1/24',
  $public_network  = '127.0.0.1/24'
) {

  class { 'ceph::conf':
    fsid            => $fsid,
    auth_type       => 'cephx',
    cluster_network => $cluster_network,
    public_network  => $public_network,
    enable_service  => true
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  }

}
