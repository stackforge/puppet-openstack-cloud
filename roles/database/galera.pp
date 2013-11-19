#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
#          Dimitri Savineau <dimitri.savineau@enovance.com> (MySQL Optimization)
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
# MySQL Galera Node
#

class os_role_galera (
    $local_ip = $ipaddress,
    $service_provider = sysv,
) {

  if ! defined(Class['xinetd']) {
    class{'xinetd': }
  }


  class { 'mysql::server':
    config_hash       => {
      'bind_address'  => $local_ip,
      'root_password' => $os_params::mysql_password,
    }
  }


  package{'libdbd-mysql-perl':}
}
