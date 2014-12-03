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
# == Class: cloud::sanity::tempest
#
# Install Tempest
#
# === Parameters:
#
class cloud::sanity::tempest (
  $bla = false,
){

  $compute_enabled = query_nodes("Anchor['create nova-api anchor']")
  if size($compute_enabled) >= 1 {
    $compute_service = true
  } else {
    $compute_service = false
  }

  tempest_config {
    'service_available/nova': value => $compute_service
  }

}
