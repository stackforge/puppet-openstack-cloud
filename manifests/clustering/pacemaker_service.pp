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
#   (optional) Name of the service to be put under Pacemaker control
#   Defaults to $name
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
#   (optional) A list of resources that should be colocated with this
#   one
#   Example: ["service2","service3"]
#   Defaults to []
#
# [*start_after*]
#   (optional) A list of resources that should be started before this
#   resource can be started. This will create a set of order constraints
#   where every resourece in $start_after should be started before this
#   resource can start
#   Example: ["service2","service3"]
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
#    colocated_services => ["openstack-keystone"],
#    start_after        => ["openstack-keystone"],
#    requires           => Package['openstack-glance'],
#  }
define cloud::clustering::pacemaker_service (
  $service_name       = $name,
  $primitive_class    = 'systemd',
  $primitive_provider = false,
  $primitive_type     = $service_name,
  $clone              = false,
  $colocated_services = [],
  $start_after        = [],
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

  if $colocated_services {
    cloud::clustering::pacemaker_colocation { $service_name :
      service        => $service_name,
      colocated_with => $colocated_services
    }
  }

  if $start_after {
    cloud::clustering::pacemaker_order { $service_name :
      first   => $start_after,
      service => $service_name
    }
  }
}
