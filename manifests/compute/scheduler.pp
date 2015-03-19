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
# == Class: cloud::compute::scheduler
#
# Compute Scheduler node
#
# === Parameters:
#
# [*scheduler_default_filters*]
#   (optional) A comma separated list of filters to be used by default
#   Defaults to false
#
# [*ram_allocation_ratio*]
#   (optional) Virtual ram to physical ram allocation ratio.
#   Defaults to '1.5' (floating point value)
#
# [*cpu_allocation_ratio*]
#   (optional) Virtual CPU to physical CPU allocation ratio.
#   Defaults to '16.0' (floating point value)
#
# [*disk_allocation_ratio*]
#   (optional) Virtual disk to physical disk allocation ratio.
#   Defaults to '1.0' (floating point value)
#
class cloud::compute::scheduler(
  $scheduler_default_filters = false,
  $ram_allocation_ratio      = '1.5',
  $cpu_allocation_ratio      = '16.0',
  $disk_allocation_ratio     = '1.0'
){

  include 'cloud::compute'

  class { 'nova::scheduler':
    enabled => true,
  }

  class { 'nova::scheduler::filter':
    scheduler_default_filters => $scheduler_default_filters,
    ram_allocation_ratio      => $ram_allocation_ratio,
    cpu_allocation_ratio      => $cpu_allocation_ratio,
    disk_allocation_ratio     => $disk_allocation_ratio
  }

}
