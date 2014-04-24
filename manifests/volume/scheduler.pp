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
# Volume Scheduler node
#

class cloud::volume::scheduler(
  # Maintain backward compatibility for multi-backend
  $volume_multi_backend = false
) {

  include 'cloud::volume'

  if ! $volume_multi_backend {
    $scheduler_driver_real    = false
  } else {
    $scheduler_driver_real = 'cinder.scheduler.filter_scheduler.FilterScheduler'
  }

  class { 'cinder::scheduler':
    scheduler_driver => $scheduler_driver_real
  }

}
