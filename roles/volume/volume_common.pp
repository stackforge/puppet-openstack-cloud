#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Volume controller

class os_volume_common {
  $encoded_user = uriescape($os_params::cinder_db_user)
  $encoded_password = uriescape($os_params::cinder_db_password)


  class { 'cinder::base':
    verbose             => false,
    sql_connection      => "mysql://${encoded_user}:${encoded_password}@${os_params::cinder_db_host}/cinder?charset=utf8",
    rabbit_userid       => 'cinder',
    rabbit_hosts        => $os_params::rabbit_hosts,
    rabbit_password     => $os_params::rabbit_password,
    rabbit_virtual_host => '/',
  }

  class { 'cinder::scheduler': }

  class { 'cinder::api':
    keystone_password      => $os_params::ks_cinder_password,
    keystone_auth_host     => $os_params::ks_keystone_internal_host,
  }

  class { 'cinder::ceilometer': }

  cinder_config{
    'DEFAULT/glance_host':          value => "${os_params::glance_host}:9292";
    'DEFAULT/syslog_log_facility':  value => 'LOG_LOCAL0';
    'DEFAULT/use_syslog':           value => 'yes';
    'DEFAULT/idle_timeout':         value => '60';
  }

}
