#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
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
# Used by Controller, Storage, Network and Compute nodes
#

class os_telemetry_common(
  
){

  class { 'ceilometer':
    metering_secret => $os_params::ceilometer_secret,
    rabbit_hosts    => $os_params::rabbit_hosts,
    rabbit_password => $os_params::rabbit_password,
    rabbit_userid   => 'ceilometer',
    verbose         => false,
    debug           => false,
  }

  ceilometer_config {
    'DEFAULT/syslog_log_facility':               value => 'LOG_LOCAL0';
    'DEFAULT/use_syslog':                        value => 'yes';
  }

  class { 'ceilometer::agent::auth':
    auth_url      => "http://${os_params::ks_keystone_internal_host}:${os_params::keystone_port}/v2.0",
    auth_password => $os_params::ks_ceilometer_password,
  }
}
