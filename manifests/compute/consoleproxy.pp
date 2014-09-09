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
# Compute Proxy Console node
#
# [*secure*]
# (optionnal) Enabled or not WSS in spice-html5 code
# Defaults to false.
#

class cloud::compute::consoleproxy(
  $api_eth    = '127.0.0.1',
  $spice_port = '6082',
  $secure     = false,
){

  include 'cloud::compute'

  class { 'nova::spicehtml5proxy':
    enabled => true,
    host    => $api_eth
  }

  # Horrible Hack to allow spice-html5 to connect on the web service
  # by SSL. Since "ws" is hardcoded, there is no way to use HTTPS otherwise.
  if $secure {
    exec { 'enable_wss_spice_html5':
      command => '/bin/sed -i "s/ws:\/\//wss:\/\//g" /usr/share/spice-html5/spice_auto.html',
      unless  => '/bin/grep -F "wss://" /usr/share/spice-html5/spice_auto.html',
    }
  }

  @@haproxy::balancermember{"${::fqdn}-compute_spice":
    listening_service => 'spice_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $spice_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
