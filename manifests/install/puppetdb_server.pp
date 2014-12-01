#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::install::puppetdb_server
#
# Configure the puppetdb server
#
class cloud::install::puppetdb_server {

  Exec {
    path   => '/usr/bin',
    notify => Service['puppetdb'],
  }

  file {
    "cp /var/lib/puppet/ssl/certs/${::fqdn}.pem /etc/puppetdb/ssl/public.pem && chown puppet:puppet /etc/puppetdb/ssl/public.pem" :
      unless => 'stat /etc/puppetdb/ssl/public.pem';
    "cp /var/lib/puppet/ssl/private_keys/${::fqdn}.pem /etc/puppetdb/ssl/private.pem && chown puppet:puppet /etc/puppetdb/ssl/private.pem" :
      unless => 'stat /etc/puppetdb/ssl/private.pem';
    'cp /var/lib/puppet/ssl/certs/ca.pem /etc/puppetdb/ssl/ca.pem && chown puppet:puppet /etc/puppetdb/ssl/ca.pem' :
      unless => 'stat /etc/puppetdb/ssl/ca.pem';
  }

  include ::puppetdb::server

}
