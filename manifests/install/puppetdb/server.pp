#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::install::puppetdb::server
#
# Configure the puppetdb server
#
class cloud::install::puppetdb::server {

  include ::puppetdb
  include ::apache

  apache::vhost { 'puppetdb' :
    docroot    => '/tmp',
    ssl        => true,
    ssl_cert   => '/etc/puppet/ssl/puppetdb.pem',
    ssl_key    => '/etc/puppet/ssl/puppetdb.pem',
    port       => '8081',
    servername => $::fqdn,
    proxy_pass => [
      {
        'path' => '/',
        'url'  => 'http://localhost:8080/'
      }
    ],
    require    => Class['::puppetdb'],
  }

}
