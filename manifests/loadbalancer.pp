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
# == Class: cloud::loadbalancer
#
# Install Load-Balancer node (HAproxy + Keepalived)
#
# === Parameters:
#
# [*keepalived_public_interface*]
#   (optional) Networking interface to bind the VIP connected to public network.
#   Defaults to 'eth0'
#
# [*keepalived_internal_interface*]
#   (optional) Networking interface to bind the VIP connected to internal network.
#   keepalived_internal_ipvs should be configured to enable the internal VIP.
#   Defaults to 'eth1'
#
# [*keepalived_public_ipvs*]
#   (optional) IP address of the VIP connected to public network.
#   Should be an array.
#   Defaults to ['127.0.0.1']
#
# [*keepalived_internal_ipvs*]
#   (optional) IP address of the VIP connected to internal network.
#   Should be an array.
#   Defaults to false (disabled)
#
# [*keepalived_interface*]
#   (optional) Networking interface to bind the VIP connected to internal network.
#   DEPRECATED: use keepalived_public_interface instead.
#   Defaults to false (disabled)
#
# [*keepalived_ipvs*]
#   (optional) IP address of the VIP connected to public network.
#   DEPRECATED: use keepalived_public_ipvs instead.
#   Should be an array.
#   Defaults to false (disabled)
#
class cloud::loadbalancer(
  $swift_api                        = true,
  $ceilometer_api                   = true,
  $cinder_api                       = true,
  $glance_api                       = true,
  $glance_registry                  = true,
  $neutron_api                      = true,
  $heat_api                         = true,
  $heat_cfn_api                     = true,
  $heat_cloudwatch_api              = true,
  $nova_api                         = true,
  $ec2_api                          = true,
  $metadata_api                     = true,
  $keystone_api_admin               = true,
  $keystone_api                     = true,
  $horizon                          = true,
  $horizon_ssl                      = false,
  $spice                            = true,
  $haproxy_auth                     = 'admin:changeme',
  $keepalived_state                 = 'BACKUP',
  $keepalived_priority              = 50,
  $keepalived_public_interface      = 'eth0',
  $keepalived_public_ipvs           = ['127.0.0.1'],
  $keepalived_internal_interface    = 'eth1',
  $keepalived_internal_ipvs         = false,
  $ks_cinder_public_port            = 8776,
  $ks_ceilometer_public_port        = 8777,
  $ks_ec2_public_port               = 8773,
  $ks_glance_api_public_port        = 9292,
  $ks_glance_registry_internal_port = 9191,
  $ks_heat_public_port              = 8004,
  $ks_heat_cfn_public_port          = 8000,
  $ks_heat_cloudwatch_public_port   = 8003,
  $ks_keystone_admin_port           = 35357,
  $ks_keystone_public_port          = 5000,
  $ks_metadata_public_port          = 8775,
  $ks_neutron_public_port           = 9696,
  $ks_nova_public_port              = 8774,
  $ks_swift_public_port             = 8080,
  $horizon_port                     = 80,
  $spice_port                       = 6082,
  $vip_public_ip                    = '127.0.0.2',
  $galera_ip                        = '127.0.0.1',
  # Deprecated parameters
  $keepalived_interface             = false,
  $keepalived_ipvs                  = false,
){

  # Manage deprecation when using old parameters
  if $keepalived_interface {
    warning('keepalived_interface parameter is deprecated. Use internal/external parameters instead.')
    $keepalived_public_interface_real = $keepalived_interface
  } else {
    $keepalived_public_interface_real = $keepalived_public_interface
  }
  if $keepalived_ipvs {
    warning('keepalived_ipvs parameter is deprecated. Use internal/external parameters instead.')
    $keepalived_public_ipvs_real = $keepalived_ipvs
  } else {
    $keepalived_public_ipvs_real = $keepalived_public_ipvs
  }

  # Ensure Keepalived is started before HAproxy to avoid binding errors.
  class { 'keepalived': } ->
  class { 'haproxy': }

  keepalived::vrrp_script { 'haproxy':
    name_is_process => true
  }

  keepalived::instance { '1':
    interface     => $keepalived_public_interface_real,
    virtual_ips   => unique(split(join(flatten([$keepalived_public_ipvs_real, ['']]), " dev ${keepalived_public_interface_real},"), ',')),
    state         => $keepalived_state,
    track_script  => ['haproxy'],
    priority      => $keepalived_priority,
    notify_master => '"/etc/init.d/haproxy start"',
    notify_backup => '"/etc/init.d/haproxy stop"',
  }

  if $keepalived_internal_ipvs {
    keepalived::instance { '2':
      interface     => $keepalived_internal_interface,
      virtual_ips   => unique(split(join(flatten([$keepalived_internal_ipvs, ['']]), " dev ${keepalived_internal_interface},"), ',')),
      state         => $keepalived_state,
      track_script  => ['haproxy'],
      priority      => $keepalived_priority,
      notify_master => '"/etc/init.d/haproxy start"',
      notify_backup => '"/etc/init.d/haproxy stop"',
    }
  }

  file { '/etc/logrotate.d/haproxy':
    ensure  => file,
    source  => 'puppet:///modules/cloud/logrotate/haproxy',
    owner   => root,
    group   => root,
    mode    => '0644';
  }

  haproxy::listen { 'monitor':
    ipaddress => $vip_public_ip,
    ports     => '9300',
    options   => {
      'mode'        => 'http',
      'monitor-uri' => '/status',
      'stats'       => ['enable','uri     /admin','realm   Haproxy\ Statistics',"auth    ${haproxy_auth}", 'refresh 5s' ],
      ''            => template('cloud/loadbalancer/monitor.erb'),
    }
  }

  if $keystone_api {
    cloud::loadbalancer::listen_http {
      'keystone_api_cluster':
        ports     => $ks_keystone_public_port,
        listen_ip => $vip_public_ip;
      'keystone_api_admin_cluster':
        ports     => $ks_keystone_admin_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $swift_api {
    cloud::loadbalancer::listen_http{
      'swift_api_cluster':
        ports     => $ks_swift_public_port,
        httpchk   => 'httpchk /healthcheck',
        listen_ip => $vip_public_ip;
    }
  }
  if $nova_api {
    cloud::loadbalancer::listen_http{
      'nova_api_cluster':
        ports     => $ks_nova_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $ec2_api {
    cloud::loadbalancer::listen_http{
      'ec2_api_cluster':
        ports     => $ks_ec2_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $metadata_api {
    cloud::loadbalancer::listen_http{
      'metadata_api_cluster':
        ports     => $ks_metadata_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $spice {
    cloud::loadbalancer::listen_http{
      'spice_cluster':
        ports     => $spice_port,
        listen_ip => $vip_public_ip,
        httpchk   => 'httpchk GET /';
    }
  }
  if $glance_api {
    cloud::loadbalancer::listen_http{
      'glance_api_cluster':
        ports     => $ks_glance_api_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $glance_registry {
    cloud::loadbalancer::listen_http{
      'glance_registry_cluster':
        ports     => $ks_glance_registry_internal_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $neutron_api {
    cloud::loadbalancer::listen_http{
      'neutron_api_cluster':
        ports     => $ks_neutron_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $cinder_api {
    cloud::loadbalancer::listen_http{
      'cinder_api_cluster':
        ports     => $ks_cinder_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $ceilometer_api {
    cloud::loadbalancer::listen_http{
      'ceilometer_api_cluster':
        ports     => $ks_ceilometer_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cluster':
        ports     => $ks_heat_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_cfn_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cfn_cluster':
        ports     => $ks_heat_cfn_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_cloudwatch_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cloudwatch_cluster':
        ports     => $ks_heat_cloudwatch_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $horizon {
    if $horizon_ssl {
      cloud::loadbalancer::listen_https{
        'horizon_cluster':
          ports     => $horizon_port,
          listen_ip => $vip_public_ip;
      }
    } else {
      cloud::loadbalancer::listen_http{
        'horizon_cluster':
          ports     => $horizon_port,
          listen_ip => $vip_public_ip;
      }
    }
  }

  haproxy::listen { 'galera_cluster':
    ipaddress          => $galera_ip,
    ports              => 3306,
    options            => {
      'mode'           => 'tcp',
      'balance'        => 'roundrobin',
      'option'         => ['tcpka', 'tcplog', 'httpchk'], #httpchk mandatory expect 200 on port 9000
      'timeout client' => '400s',
      'timeout server' => '400s',
    }
  }

}
