#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::network::contrail::rabbitmq
#
# This resource creates RabbitMQ resources for Contrail
#
# == Parameters:
#
# [*user*]
#   (optional) The username to use when connecting to Rabbit
#   Defaults to 'contrail'
#
# [*password*]
#   (optional) The password to use when connecting to Rabbit
#   Defaults to 'contrailpassword'
#
# [*vhost*]
#   (optional) The virtual host to use when connecting to Rabbit
#   Defaults to '/'
#
# [*is_admin*]
#   (optional) If the user should be admin or not
#   Defaults to true
#
# [*configure_permission*]
#   (optional) Define configure permission
#   Defaults to '.*'
#
# [*write_permission*]
#   (optional) Define write permission
#   Defaults to '.*'
#
# [*read_permission*]
#   (optional) Define read permission
#   Defaults to '.*'
#
class cloud::network::contrail::rabbitmq (
  $user                 = 'contrail',
  $password             = 'contrailpassword',
  $vhost                = '/',
  $is_admin             = true,
  $configure_permission = '.*',
  $write_permission     = '.*',
  $read_permission      = '.*',
) {

  rabbitmq_user { $user :
    admin    => $is_admin,
    password => $password,
    provider => 'rabbitmqctl',
  }

  rabbitmq_vhost { $vhost :
    provider => 'rabbitmqctl',
  }

  rabbitmq_user_permissions { "${user}@${vhost}" :
    configure_permission => $configure_permission,
    write_permission     => $write_permission,
    read_permission      => $read_permission,
    provider             => 'rabbitmqctl',
  }

}
