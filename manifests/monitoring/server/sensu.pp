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
# [*checks*]
#   (optionnal) Hash of checks and their respective options
#   Defaults to {}.
#   Example :
#     $checks = {
#       'ntp' => {
#          'command' => '/etc/sensu/plugins/check-ntp.sh'},
#       'http' => {
#          'command' => '/etc/sensu/plugins/check-http.sh'},
#     }
#
# [*handlers*]
#   (optionnal) Hash of handlers and their respective options
#   Defaults to {}.
#   Example :
#     $handlers = {
#       'mail' => {
#          'command' => 'mail -s "Sensu Alert" contact@example.com'},
#     }
#
# [*plugins*]
#   (optionnal) Hash of handlers and their respective options
#   Defaults to {}.
#   Example :
#     $plugins = {
#       'http://www.example.com/ntp.sh' => {
#          'type'         => 'url',
#          'install_path' => '/etc/sensu/plugins',
#       }
#     }
#
# [*rabbitmq_user*]
#   (optionnal) Rabbitmq user
#   Defaults to 'sensu'
#
# [*rabbitmq_password*]
#   (optionnal) Rabbitmq_password
#   Defaults to 'rabbitpassword'
#
# [*rabbitmq_vhost*]
#   (optionnal) Rabbitmq vhost
#   Defaults to '/sensu'
#
# [*sensu_api_ip*]
#   (optionnal) IP address to bind the sensu_api to
#   Defaults to '%{::ipaddress}'
#
# [*sensu_api_port*]
#   (optionnal) Port to bind the sensu_api to
#   Defaults to '4567'
#
# [*uchiwa_ip*]
#   (optionnal) IP address to bind uchiwa to
#   Defaults to '%{::ipaddress}'
#
# [*uchiwa_port*]
#   (optionnal) Port to bind uchiwa to
#   Defaults to '3000'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::monitoring::server::sensu (
  $checks                    = {},
  $handlers                  = {},
  $plugins                   = {},
  $rabbitmq_user             = 'sensu',
  $rabbitmq_password         = 'rabbitpassword',
  $rabbitmq_vhost            = '/sensu',
  $sensu_api_ip              = $::ipaddress,
  $sensu_api_port            = '4567',
  $uchiwa_ip                 = $::ipaddress,
  $uchiwa_port               = '3000',
  $firewall_settings         = {},
) {

  include cloud::params

  $rabbitmq_user_realized = query_nodes("Rabbitmq_user['${rabbitmq_user}']")
  $rabbitmq_vhost_realized = query_nodes("Rabbitmq_vhost['${rabbitmq_vhost}']")
  $rabbitmq_user_permissions_realized = query_nodes("Rabbitmq_user_permissions['${rabbitmq_user}@${rabbitmq_vhost}']")

  if size($rabbitmq_user_realized) == 0 {
    @@rabbitmq_user { $rabbitmq_user :
      password => $rabbitmq_password,
    }
  }
  if size($rabbitmq_vhost_realized) == 0 {
    @@rabbitmq_vhost { $rabbitmq_vhost :
      ensure  => present,
    }
  }
  if size($rabbitmq_user_permissions_realized) == 0 {
    @@rabbitmq_user_permissions { "${rabbitmq_user}@${rabbitmq_vhost}" :
      configure_permission => '.*',
      read_permission      => '.*',
      write_permission     => '.*',
    }
  }

  if size($rabbitmq_user_realized) >= 1 {

    Service["${::cloud::params::redis_service_name}"] -> Service['sensu-api'] -> Service['sensu-server'] -> Service['uchiwa']
    Service['sensu-server'] -> Sensu::Plugin <<| |>>


    include cloud::monitoring::agent::sensu

    create_resources('sensu::check', $checks)
    create_resources('sensu::handler', $handlers)
    create_resources('@@sensu::plugin', $plugins)

    include ::uchiwa
    uchiwa::api { 'OpenStack' :
      host => $uchiwa_ip,
      port => $uchiwa_port,
    }

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ '100 allow sensu_dashboard access':
        port   => $uchiwa_port,
        extras => $firewall_settings,
      }

      cloud::firewall::rule{ '100 allow sensu_api access':
        port   => $sensu_api_port,
        extras => $firewall_settings,
      }
    }

    @@haproxy::balancermember{"${::fqdn}-sensu_dashboard":
      listening_service => 'sensu_dashoard',
      server_names      => $::hostname,
      ipaddresses       => $uchiwa_ip,
      ports             => $uchiwa_port,
      options           => 'check inter 2000 rise 2 fall 5'
    }

    @@haproxy::balancermember{"${::fqdn}-sensu_api":
      listening_service => 'sensu_api',
      server_names      => $::hostname,
      ipaddresses       => $sensu_api_ip,
      ports             => $sensu_api_port,
      options           => 'check inter 2000 rise 2 fall 5'
    }
  }

}
