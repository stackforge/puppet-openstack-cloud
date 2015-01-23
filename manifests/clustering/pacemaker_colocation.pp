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
# Its only input is the name, in the form "service1,service2", and creates
# a colocation rule to run service1 and service2 together

define cloud::clustering::pacemaker_colocation {
  $value = split($name,',')
  $service1 = $value[0]
  $service2 = $value[1]
  $colocation_name = "${service1}-with-${service2}"

  cs_colocation { $colocation_name:
    primitives => [ "p_${service1}", "p_${service2}" ],
  }
}
