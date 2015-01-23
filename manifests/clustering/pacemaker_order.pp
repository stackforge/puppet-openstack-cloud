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
# Its only input is the name, in the form "service1,service2", and creates
# an order constraint to run service1 before service2

define cloud::clustering::pacemaker_order
{
  $value = split($name,',')
  $first = $value[0]
  $second = $value[1]

  $order_name = "${first}-before-${second}"

  cs_order{ $order_name :
    first  => "p_${first}",
    second => "p_${second}",
  }
}
