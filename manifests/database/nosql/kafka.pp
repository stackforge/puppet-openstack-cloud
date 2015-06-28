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
# == Class: cloud::database::nosql::kafka
#
# Install a Kafka broket
#
# === Parameters:
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::nosql::kafka (
  $firewall_settings = {},
){

  include ::kafka::broker

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow kafka access':
      port   => '9092',
      extras => $firewall_settings,
    }
  }

}
