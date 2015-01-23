#
# Copyright (C) 2015 Red Hat Inc.
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
# Configure a service to be controlled by Pacemaker
#
#
# === Parameters
#
# [*service_name*]
#   (required) Name of the service to be put under Pacemaker control
#
# [*primitive_class*]
#   (optional) Pacemaker primitive class
#   Defaults to 'systemd'
#
# [*primitive_provider*]
#   (optional) Pacemaker primitive provider for OCF scripts
#   Examples: 'ocf','heartbeat'
#   Defaults to false
#
# [*primitive_type*]
#   (optional) The type of the primitive: OCF file name, or operating
#   system-native service if using systemd, upstart or lsb as
#   primitive_class
#   Defaults to $service_name
#
# [*clone*]
#   (optional) Create a cloned resource
#   Defaults to false
#
# [*colocated_services*]
#   (optional) A list of services that should be colocated when
#   creating the Pacemaker resource, specified as comma-separated
#   strings
#   Example: ["service1,service2","service1,service3"] would create
#   colocation rules for service1 and service2, and then for service1
#   and service3.
#   Defaults to []
#
# [*start_order*]
#   (optional) A list of start order constraints to be created when
#   creating the Pacemaker resource, specified as comma-separated
#   strings
#   Example: ["service1,service2","service1,service3"] would create
#   order rules where service1 starts before service2 and service3.
#   Defaults to []
#
# [*requires*]
#   (optional) A list of required Puppet resources
#   Defaults to []
#
# Example:
#  cloud::clustering::pacemaker_service { 'openstack-glance-api' :
#    service_name       => 'openstack-glance-api',
#    primitive_class    => 'systemd',
#    primitive_provider => false,
#    primitive_type     => 'openstack-glance-api',
#    clone              => false,
#    colocated_services => ["openstack-keystone,openstack-glance-api"],
#    start_order        => ["openstack-keystone,openstack-glance-api"],
#    requires           => Package['openstack-glance'],
#  }


define cloud::clustering::pacemaker_service (
  $service_name,
  $primitive_class    = 'systemd',
  $primitive_provider = false,
  $primitive_type     = $service_name,
  $clone              = false,
  $colocated_services = [],
  $start_order        = [],
  $requires           = [],
) {

  openstack_extras::pacemaker::service { $service_name :
    ensure             => present,
    metadata           => {},
    ms_metadata        => {},
    operations         => {},
    parameters         => {},
    primitive_class    => $primitive_class,
    primitive_provider => $primitive_provider,
    primitive_type     => $primitive_type,
    use_handler        => false,
    clone              => $clone,
    require            => $requires,
  }

  if !empty($colocated_services) {
    cloud::clustering::pacemaker_colocation { $colocated_services: }
  }

  if !empty($start_order) {
    cloud::clustering::pacemaker_order { $start_order: }
  }
}
