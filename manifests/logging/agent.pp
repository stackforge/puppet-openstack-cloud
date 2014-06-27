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
# == Class: cloud::logging::agent
#
# Configure logging agent
#
# === Parameters:
#
# [*server*]
#   (optional) IP address or hostname of the logging server
#   Defaults to '127.0.0.1'
#
# [*sources*]
#   (optional) Fluentd sources
#   Defaults to empty hash
#
class cloud::logging::agent(
  $server = '127.0.0.1',
  $sources = {},
){

  include cloud::logging

  resources {'fluentd::configfile':
    purge => true,
  }
  resources {'fluentd::source' :
    purge => true,
  }

  file { '/var/db':
    ensure => directory,
  } ->
  file { '/var/db/td-agent':
    ensure  => 'directory',
    owner   => 'td-agent',
    group   => 'td-agent',
    require => Class['fluentd'],
  }

  create_resources('fluentd::configfile', keys($sources))
  create_resources('fluentd::source', $sources)

  fluentd::match { 'forward_main':
    configfile => 'forward',
    pattern    => '**',
    type       => 'forward',
    servers    => [ { 'host' => $server } ]
  }

}
