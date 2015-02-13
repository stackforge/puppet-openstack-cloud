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
# Configure a Pacemaker order constraint
#
# === Parameters
#
# [*first*]
#   (required) List of services to be executed before $service
#   Should be an array.
#   Defaults to []
#
# [*service*]
#   (optional) Service to be executed after all services in $first
#   Defaults to $name
#
# [*order*]
#   (optional) Do not use in a manifest. It is used to iterate
#   through the list of services to be executed before $service.
#   Defaults to '0'
define cloud::clustering::pacemaker_order(
  $first   = [],
  $service = $name,
  $order   = '0'
) {
  $service1 = inline_template('<%= @first[@order.to_i] %>')
  if $service1 {
    $order_name = "${service1}-before-${service}"

    cs_order { $order_name :
      first  => "p_${service1}",
      second => "p_${service}",
    }

    $neworder = inline_template('<%= @order.to_i + 1 %>')

    cloud::clustering::pacemaker_order { "${service}-${neworder}":
      first   => $first,
      service => $service,
      order   => $neworder
    }
  }
}
