#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::database::nosql::redis::sentinel
#
# Install a Redis sentinel node (used by OpenStack & monitoring services)
#
# === Parameters:
#
# [*port*]
#   (optional) Port where Redis is binded.
#   Used for firewall purpose.
#   Default to 26379
#
# [*haproxy_monitor_ip*]
#   (optional) IP on which the HAProxy API is listening on
#   Used for redis master failover purpose
#   Default to 127.0.0.1
#
# [*haproxy_monitor_port*]
#   (optional) Port on which the HAProxy API is listening on
#   Used for redis master failover purpose
#   Default to 10300
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::nosql::redis::sentinel(
  $port                 = 26379,
  $haproxy_monitor_ip   = '127.0.0.1',
  $haproxy_monitor_port = '10300',
  $firewall_settings    = {},
) {

  include ::redis::sentinel

  file { '/bin/redis-notifications.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('cloud/database/redis-notifications.sh.erb'),
    before  => Service['redis-sentinel'],
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow redis sentinel access':
      port   => $port,
      extras => $firewall_settings,
    }
  }

}
