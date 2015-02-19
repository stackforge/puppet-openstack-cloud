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
# Configure a Pacemaker colocation rule
#
# === Parameters
#
# [*service*]
#   (required) Name of the service to be colocated with others
#   Defaults to $name
#
# [*colocated_with*]
#   (optional) List of services to be colocated with service1
#   Should be an array.
#   Defaults to []
#
# [*order*]
#   (optional) Do not use in a manifest. It is used to iterate
#   through the list of services to be colocated with $service.
#   Defaults to '0'
define cloud::clustering::pacemaker_colocation(
  $service        = $name,
  $colocated_with = [],
  $order          = '0'
) {
  $service1 = inline_template('<%= @colocated_with[@order.to_i] %>')
  if $service1 {
    $colocation_name = "${service}-with-${service1}"

    cs_colocation { $colocation_name :
      primitives => [ "p_${service}", "p_${service1}" ],
    }

    $neworder = inline_template('<%= @order.to_i + 1 %>')

    cloud::clustering::pacemaker_colocation { "${service}-${neworder}":
      service        => $service,
      colocated_with => $colocated_with,
      order          => $neworder
    }
  }
}

