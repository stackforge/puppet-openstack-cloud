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
# == Class: cloud::database::nosql::elasticsearch
#
# Install an ElasticSearch server
#
# === Parameters:
#
# [*listen_port*]
#   (optional) Port on which ElasticSearch instance should listen
#   Defaults to '9200'
#
# [*listen_ip*]
#   (optional) IP address on which ElasticSearch instance should listen
#   Defaults to '127.0.0.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::nosql::elasticsearch (
  $listen_port       = '9200',
  $listen_ip         = '127.0.0.1',
  $firewall_settings = {},
){

  include ::elasticsearch

  @@haproxy::balancermember{"${::fqdn}-es_cluster":
    listening_service => 'elasticsearch',
    server_names      => $::hostname,
    ipaddresses       => $listen_ip,
    ports             => $listen_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow elasticsearch access':
      port   => $listen_port,
      extras => $firewall_settings,
    }
  }

}
