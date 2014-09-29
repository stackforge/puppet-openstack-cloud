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
# == Class: cloud::messaging
#
# Install Messsaging Server (RabbitMQ)
#
# === Parameters:
#
# [*rabbit_names*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to $::hostname
#
# [*rabbit_password*]
#   (optional) Password to connect to OpenStack queues.
#   Defaults to 'rabbitpassword'
#
# [*cluster_node_type*]
#   (optionnal) Store the queues on the disc or in the RAM.
#   Could be set to 'disk' or 'ram'.
#   Defaults to 'disc'

class cloud::messaging(
  $cluster_node_type = 'disc',
  $rabbit_names      = $::hostname,
  $rabbit_password   = 'rabbitpassword'
){

  # we ensure having an array
  $array_rabbit_names = any2array($rabbit_names)

  Class['rabbitmq'] -> Rabbitmq_vhost <<| |>>
  Class['rabbitmq'] -> Rabbitmq_user <<| |>>
  Class['rabbitmq'] -> Rabbitmq_user_permissions <<| |>>

  # Packaging issue: https://bugzilla.redhat.com/show_bug.cgi?id=1033305
  if $::osfamily == 'RedHat' {
    file {'/usr/sbin/rabbitmq-plugins':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-plugins'
    }

    file {'/usr/sbin/rabbitmq-env':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-env'
    }
  }

  class { 'rabbitmq':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_nodes            => $array_rabbit_names,
    wipe_db_on_cookie_change => true,
    cluster_node_type        => $cluster_node_type
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq'],
  }
  rabbitmq_user { ['nova','glance','neutron','cinder','ceilometer','heat','trove']:
    admin    => true,
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq']
  }
  rabbitmq_user_permissions {[
    'nova@/',
    'glance@/',
    'neutron@/',
    'cinder@/',
    'ceilometer@/',
    'heat@/',
    'trove@/',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

}
