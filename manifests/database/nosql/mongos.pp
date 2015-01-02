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
# == Class: cloud::database::nosql::mongos
#
# Install and configure mongos (daemon responsible for sharding in MongoDB)
#
# === Parameters:
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*mongos_cfg_server*]
#   (optional) Array of config server the mongos process will connect to
#   Sould be an array. Example ['configsvr1:27019', 'configsvr2:27019']
#   Defaults to []
#
# [*mongos_shards*]
#   (optional) Hashes of MongoDB shards
#   Sould be an Hash.
#   Example { 'ceilometer' => {'member' => 'node1:27018', 'keys' => [{'ceilometer.coll' => {'name' => 1}]}}
#   Defaults to {}
#
# [*enabled*]
#   (optional) Should the mongos service be enabled
#   Sould be a boolean
#   Defaults to true
#
class cloud::database::nosql::mongos(
  $firewall_settings = {},
  $mongos_cfg_server = [],
  $mongos_shard      = {},
  $enable            = true,
) {

  # Red Hat & CentOS use packages from RHCL or EPEL to support systemd
  # so manage_package_repo should be at false regarding to mongodb module
  if $::osfamily == 'RedHat' {
    $manage_package_repo = false
  } else {
  # Debian & Ubuntu are picked from mongodb repo to get recent version
    $manage_package_repo = true
  }

  if ! defined(Class['mongodb::globals']) {
    class { 'mongodb::globals':
      manage_package_repo => $manage_package_repo
    }
  }

  if $enable {
    class {'mongodb::mongos' :
      configdb => $mongos_cfg_server,
    }
  }

  create_resources('mongodb_shard', $mongos_shard, { 'require' => 'Class[mongodb::mongos]' })

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow mongodb access':
      port   => $bind_port,
      extras => $firewall_settings,
    }
  }

}
