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
# Define::
#
# cloud::loadbalancer::listen_http
#
define cloud::loadbalancer::listen_http(
  $ports     = 'unset',
  $httpchk   = 'httpchk',
  $listen_ip = '0.0.0.0') {

  haproxy::listen { $name:
    ipaddress => $listen_ip,
    ports     => $ports,
    options   => {
      'mode'        => 'http',
      'balance'     => 'roundrobin',
      'option'      => ['tcpka', 'tcplog', $httpchk],
      'http-check'  => 'expect ! rstatus ^5',
    }
  }
}
