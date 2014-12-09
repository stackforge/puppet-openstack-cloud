#
# Author: François Charlier <francois.charlier@enovance.com>
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
# = Class: cloud::storage::rbd::standaloneclient
#
# This class aims to be used when the Ceph cluster is not installed,
# bootstrapped, configured with puppet-openstack-cloud.
# It provides the necessary shims to allow using the ceph features in
# cloud::compute::hypervisor, cloud::image::api and cloud::volume::backend::rbd
#
# == Parameters
#
# [*monitors*]
#   (required) List of monitors addresses (not validated, can be plain IPv4,
#   IPv6 or hostnames)
#   Example: ['[2a07:9a03:1:1:ec15:7aff:fe6e:41f0]', …]
#            ['10.10.26.3', '10.10.26.4', …]
#            ['mon0.example.com', 'mon1.example.com', …]
#
# [*keys*]
#   (required) List of pairs of key names & secrets.
#   At least a key named 'admin' should be passed.
#   Example: {
#              'admin' => {
#                secret       => 'secretadmin'
#                keyring_path => '/etc/ceph/ceph.client.admin.keyring'
#              },
#              'client1' => {
#                secret       => 'secretclient1',
#                keyring_path => '/etc/ceph/ceph.client.client1.keyring'
#              }
#            }
#   Note: if path is ommited, the current default from enovance/puppet-ceph
#   will be used: '/var/lib/ceph/tmp/${name}.keyring' which might be unsafe
#

class cloud::storage::rbd::standaloneclient (
  $monitors,
  $keys
) {

  package { 'ceph-common':
    ensure => present
  }

  concat { '/etc/ceph/ceph.conf':
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    require => Package['ceph-common']
  }

  concat::fragment { 'ceph-client-os':
    target  => '/etc/ceph/ceph.conf',
    order   => '01',
    content => template('cloud/storage/ceph/ceph-simple-client.conf.erb')
  }

  create_resources('ceph::key', $keys)

}
