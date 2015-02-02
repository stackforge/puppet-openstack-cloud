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
# == Class: cloud::logging::server
#
# [*kibana_port*]
#   (optional) Port of Kibana service.
#   Defaults to '8300'
#
# [*kibana_bind_ip*]
#   (optional) Address on which kibana is listening on
#   Defaults to '127.0.0.1'
#
# [*elasticsearch_port*]
#   (optional) Port of ElasticSearch service.
#   Defaults to '9200'
#
# [*elasticsearch_bind_ip*]
#   (optional) Address on which elasticsearch is listening on
#   Defaults to '127.0.0.1'
#
class cloud::logging::server(
  kibana_port           = '8300',
  kibana_bind_ip        = '127.0.0.1',
  elasticsearch_port    = '9200',
  elasticsearch_bind_ip = '127.0.0.1',
) {

  include ::elasticsearch
  include ::kibana3
  include cloud::logging::agent
  elasticsearch::instance {'fluentd' : }

  @@haproxy::balancermember{"${::fqdn}-es_cluster":
    listening_service => 'elasticsearch',
    server_names      => $::hostname,
    ipaddresses       => $elasticsearch_bind_ip,
    ports             => $elasticsearch_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-kibana":
    listening_service => 'kibana',
    server_names      => $::hostname,
    ipaddresses       => $kibana_bind_ip,
    ports             => $kibana_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
