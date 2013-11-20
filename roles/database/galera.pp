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

class os_galera (
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

  class { 'keystone::db::mysql':
    password      => $os_params::keystone_db_password,
    user          => $os_params::keystone_db_user,
    dbname        => 'keystone',
    host          => $os_params::keystone_db_host,
    allowed_hosts => $os_params::keystone_allowed_hosts,
  }

  class { 'heat::db::mysql':
    password      => $os_params::heat_db_password,
    user          => $os_params::heat_db_user,
    dbname        => 'heat',
    host          => $os_params::heat_db_host,
  }

  class { 'glance::db::mysql':
    password      => $os_params::glance_db_password,
    user          => $os_params::glance_db_user,
    dbname        => 'glance',
    host          => $os_params::glance_db_host,
    allowed_hosts => $os_params::glance_allowed_hosts,
  }

  class { 'cinder::db::mysql':
    password      => $os_params::cinder_db_password,
    user          => $os_params::cinder_db_user,
    dbname        => 'cinder',
    host          => $os_params::cinder_db_host,
    allowed_hosts => $os_params::cinder_allowed_hosts,
  }

  class { 'nova::db::mysql':
    password      => $os_params::nova_db_password,
    user          => $os_params::nova_db_user,
    dbname        => 'nova',
    host          => $os_params::nova_db_host,
    allowed_hosts => $os_params::nova_allowed_hosts,
  }

  package{'libdbd-mysql-perl':}
}
