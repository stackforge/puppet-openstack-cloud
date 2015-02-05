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
# == Class: cloud::database::nosql::mongodb::mongod
#
# Install a MongoDB server & the replicasets
#
# === Parameters:
#
# [*enable*]
#   (optional) Should mongod be running.
#   Defaults to 'true'
#
# [*replset*]
#   (optional) MongoDB replicaset to configure
#   Define the replset to enable on the mongodb server
#   Example:
#     { 'ceilometer' => { 'members' => '10.0.0.1:27017' }}
#   Defaults to {}
#
# [*mongod_port*]
#   (optional) Port for the firewall to enable
#   Based on the mode the mongod process is started with, the port
#   it will listen on might change.
#   Defaults to '27017'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Defaults to {}
#
class cloud::database::nosql::mongodb::mongod(
  $enable            = true,
  $replset           = {},
  $mongod_port       = '27017',
  $firewall_settings = {},
) {

  if $enable {
    include ::mongodb::globals
    include ::mongodb::server
    create_resources('mongodb_replset', $replset)

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ '100 allow mongod access':
        port   => $mongod_port,
        extras => $firewall_settings,
      }
    }
  }

}
