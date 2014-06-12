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

class cloud::logging::server{

  include cloud::logging

  class { 'elasticsearch':
    config => {}
  }

  # kibana3 requires a separate vhost or a different port
  class { 'kibana3':
    ws_port => 8001,
  }

  fluentd::install_plugin { 'elasticsearch-plugin':
    ensure      => present,
    plugin_type => 'gem',
    plugin_name => 'fluent-plugin-elasticsearch',
  }

  fluentd::source { 'forward_collector':
    configfile => 'forward',
    type       => 'forward',
  }

  fluentd::match { 'forward_logs':
    configfile => 'forward',
    pattern    => '**',
    type       => 'elasticsearch',
    config     => { logstash_format => true }
  }

}
