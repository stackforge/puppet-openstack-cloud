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
# Network Controller node (API + Scheduler)
#

class cloud::network::controller(
  $neutron_db_host         = '127.0.0.1',
  $neutron_db_user         = 'neutron',
  $neutron_db_password     = 'neutronpassword',
  $ks_neutron_password     = 'neutronpassword',
  $ks_keystone_admin_host  = '127.0.0.1',
  $ks_keystone_admin_proto = 'http',
  $ks_keystone_public_port = 5000,
  $ks_neutron_public_port  = 9696,
  $api_eth                 = '127.0.0.1',
  $ks_admin_tenant         = 'admin',
  $nova_url                = 'http://127.0.0.1:8774/v2',
  $nova_admin_auth_url     = 'http://127.0.0.1:5000/v2.0',
  $nova_admin_username     = 'nova',
  $nova_admin_tenant_name  = 'services',
  $nova_admin_password     = 'novapassword',
  $nova_region_name        = 'RegionOne'
) {

  include 'cloud::network'

  $encoded_user = uriescape($neutron_db_user)
  $encoded_password = uriescape($neutron_db_password)

  class { 'neutron::server':
    auth_password       => $ks_neutron_password,
    auth_host           => $ks_keystone_admin_host,
    auth_protocol       => $ks_keystone_admin_proto,
    auth_port           => $ks_keystone_public_port,
    database_connection => "mysql://${encoded_user}:${encoded_password}@${neutron_db_host}/neutron?charset=utf8",
    mysql_module        => '2.2',
    api_workers         => $::processorcount,
    agent_down_time     => '60',
  }

  class { 'neutron::server::notifications':
    nova_url               => $nova_url,
    nova_admin_auth_url    => $nova_admin_auth_url,
    nova_admin_username    => $nova_admin_username,
    nova_admin_tenant_name => $nova_admin_tenant_name,
    nova_admin_password    => $nova_admin_password,
    nova_region_name       => $nova_region_name
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Neutron DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  Neutron_config<| |> ->
  exec {'neutron_db_sync':
    command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head',
    path    => '/usr/bin',
    user    => 'neutron',
    unless  => "/usr/bin/mysql neutron -h ${neutron_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables",
    require => 'Neutron_config[DEFAULT/service_plugins]',
    notify  => Service['neutron-server']
  }

  @@haproxy::balancermember{"${::fqdn}-neutron_api":
    listening_service => 'neutron_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_neutron_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
