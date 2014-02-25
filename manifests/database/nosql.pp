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
# == Class: cloud::database::nosql
#
# Install a nosql server (MongoDB)
#
# === Parameters:
#
# [*bind_ip*]
#   (optional) IP address on which mongod instance should listen
#   Defaults in params
#
# [*nojournal*]
#   (optional) Disable mongodb internal cache. This is not recommended for
#   production but results in a much faster boot process.
#   http://docs.mongodb.org/manual/reference/configuration-options/#nojournal
#   Defaults to false
#
# [*replset_members*]
#   (optional) Ceilometer Replica set members hostnames
#   Should be an array. Example: ['node1', 'node2', node3']
#   Default value in params
#

class cloud::database::nosql(
  $bind_ip         = '127.0.0.1',
  $nojournal       = false,
  $replset_members = ['mgmt001']
) {

  # bind_ip should be an array
  $bind_ip_real = any2array($bind_ip)

  class { 'mongodb::globals':
    manage_package_repo => true
  }->
  class { 'mongodb':
    bind_ip   => $bind_ip_real,
    nojournal => $nojournal,
    replset   => 'ceilometer',
  }

  exec {'check_mongodb' :
    command   => "/usr/bin/mongo ${bind_ip}:27017",
    logoutput => false,
    tries     => 60,
    try_sleep => 5,
    require   => Service['mongodb'],
  }

  mongodb_replset{'ceilometer':
    members => $replset_members,
    before  => Anchor['mongodb setup done'],
  }

  anchor {'mongodb setup done' :
    require => Exec['check_mongodb'],
  }

}
