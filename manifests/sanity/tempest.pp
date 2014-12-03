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
  $manage_packages = false,
  $image_name      = 'cirros',
  $public_network_name = 'pub-net',
){

  $compute_enabled = query_nodes("Anchor['create nova-api anchor']")
  if size($compute_enabled) >= 1 {
    $compute_service = true
  } else {
    $compute_service = false
  }

  $network_enabled = query_nodes("Anchor['create neutron-server anchor']")
  if size($network_enabled) >= 1 {
    $network_service = true
  } else {
    $network_service = false
  }

  $volume_enabled = query_nodes("Anchor['create cinder-api anchor']")
  if size($volume_enabled) >= 1 {
    $volume_service = true
  } else {
    $volume_service = false
  }

  $image_enabled = query_nodes("Anchor['create glance-api anchor']")
  if size($image_enabled) >= 1 {
    $image_service    = true
    $configure_images = true
  } else {
    $image_service    = false
    $configure_images = false
  }

  $telemetry_enabled = query_nodes("Anchor['create ceilometer-api anchor']")
  if size($telemetry_enabled) >= 1 {
    $telemetry_service = true
  } else {
    $telemetry_service = false
  }

  $orchestration_enabled = query_nodes("Anchor['create heat-api anchor']")
  if size($orchestration_enabled) >= 1 {
    $orchestration_service = true
  } else {
    $orchestration_service = false
  }

  $dashboard_enabled = query_nodes("Anchor['create horizon anchor']")
  if size($dashboard_enabled) >= 1 {
    $dashboard_service = true
  } else {
    $dashboard_service = false
  }

  $object_enabled = query_nodes("Anchor['create swift-api anchor']")
  if size($object_enabled) >= 1 {
    $object_service = true
  } else {
    $object_service = false
  }

  # waiting for https://review.openstack.org/#/c/138838/
  class { 'tempest':
    manage_packages      => $manage_packages,
    nova_available       => $compute_service,
    cinder_available     => $volume_service,
    neutron_available    => $network_service,
    glance_available     => $image_service,
    ceilometer_available => $telemetry_service,
    heat_available       => $orchestration_service,
    horizon_available    => $dashboard_service,
    swift_available      => $object_service,
    configure_images     => $configure_images,
    configure_networks   => false,
    image_name           => $image_name,
    public_network_name  => $public_network_name,
  }

}
