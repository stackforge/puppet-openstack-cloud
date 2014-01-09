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
# == Class: privatecloud::messaging
#
# Install Messsaging Server (RabbitMQ)
#
# === Parameters:
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Default value in params
#
# [*rabbit_password*]
#   (optional) Password to connect to OpenStack queues.
#   Default value in params
#

class privatecloud::messaging(
  $rabbit_hosts    = $os_params::rabbit_hosts,
  $rabbit_names    = $os_params::rabbit_names,
  $rabbit_password = $os_params::rabbit_password
){

  class { 'rabbitmq::server':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_disk_nodes       => $rabbit_names,
    wipe_db_on_cookie_change => true,
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq::server'],
  }
  rabbitmq_user { ['nova','glance','neutron','cinder','ceilometer','heat']:
    admin    => true,
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq::server']
  }
  rabbitmq_user_permissions {[
    'nova@/',
    'glance@/',
    'neutron@/',
    'cinder@/',
    'ceilometer@/',
    'heat@/',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

}
