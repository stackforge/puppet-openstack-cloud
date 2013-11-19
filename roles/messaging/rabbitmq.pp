#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
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

# RabbitMQ node

class os_rabbitmq{
  class { 'rabbitmq::server':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_disk_nodes       => $os_params::rabbit_names,
    wipe_db_on_cookie_change => true,
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq::server'],
  }
  rabbitmq_user { ['ceilometer']:
    admin    => true,
    password => $os_params::rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq::server']
  }
  rabbitmq_user_permissions {[
    'ceilometer@/',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

}
