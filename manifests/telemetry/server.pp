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
# Telemetry server nodes
#

class cloud::telemetry::server(
  $ks_keystone_internal_host      = '127.0.0.1',
  $ks_keystone_internal_proto     = 'http',
  $ks_ceilometer_internal_port    = '8777',
  $ks_ceilometer_password         = 'ceilometerpassword',
  $api_eth                        = '127.0.0.1',
  $mongo_nodes                    = ['127.0.0.1:27017'],
){

  warning('This class is deprecated. You should use cloud::telemetry::api,collector,alarmnotifier,alarmevaluator.')

  class { 'cloud::telemetry::api':
    ks_keystone_internal_host   => $ks_keystone_internal_host,
    ks_keystone_internal_proto  => $ks_keystone_internal_proto,
    ks_ceilometer_internal_port => $ks_ceilometer_internal_port,
    ks_ceilometer_password      => $ks_ceilometer_password,
    api_eth                     => $api_eth,
    mongo_nodes                 => $mongo_nodes,
  }
  class { 'cloud::telemetry::alarmevaluator': }
  class { 'cloud::telemetry::alarmnotifier': }
  class { 'cloud::telemetry::collector': }

}
