#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::network::contrail::database
#
# Install a Contrail database node
#
# === Parameters:
#
# [*port*]
#   (optional) Port where Kafka is bound to
#   Used for firewall purpose.
#   Default to 9042
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::contrail::database (
  $port              = 9042,
  $firewall_settings = {},
){

  include ::contrail::database

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow contrail database access':
      port   => $port,
      extras => $firewall_settings,
    }
  }

}
