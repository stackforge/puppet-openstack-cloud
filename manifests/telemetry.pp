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
# == Class: cloud::telemetry
#
# Common telemetry class, used by Controller, Storage,
# Network and Compute nodes
#
# === Parameters:
#
# [*ceilometer_secret*]
#   Secret key for signing messages.
#   Default value in params
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Default value in params
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Default value in params
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_public_host*]
#   (optional) Public Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Default value in params
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Default value in params
#
# [*debug*]
#   (optional) Set log output to debug output
#   Default value in params
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults value in params
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults value in params
#
# [*region*]
#   (optional) the keystone region of this node
#   Defaults value in params
#

class cloud::telemetry(
  $ceilometer_secret          = $os_params::ceilometer_secret,
  $rabbit_hosts               = $os_params::rabbit_hosts,
  $rabbit_password            = $os_params::rabbit_password,
  $ks_keystone_internal_host  = $os_params::ks_keystone_internal_host,
  $ks_keystone_internal_port  = $os_params::ks_keystone_internal_port,
  $ks_keystone_internal_proto = $os_params::ks_keystone_internal_proto,
  $ks_ceilometer_password     = $os_params::ks_ceilometer_password,
  $region                     = $os_params::region,
  $verbose                    = $os_params::verbose,
  $debug                      = $os_params::debug,
  $log_facility               = $os_params::log_facility,
  $use_syslog                 = $os_params::use_syslog,
){

  class { 'ceilometer':
    metering_secret => $ceilometer_secret,
    rabbit_hosts    => $rabbit_hosts,
    rabbit_password => $rabbit_password,
    rabbit_userid   => 'ceilometer',
    verbose         => $verbose,
    debug           => $debug,
    use_syslog      => $use_syslog,
    log_facility    => $log_facility
  }

  class { 'ceilometer::agent::auth':
    auth_url      => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    auth_password => $ks_ceilometer_password,
    auth_region   => $region
  }

}
