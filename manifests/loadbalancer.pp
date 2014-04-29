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
# [*swift_api*]
#   (optional) Enable or not Swift public binding.
#   Defaults to true
#
# [*ceilometer_api*]
#   (optional) Enable or not Ceilometer public binding.
#   Defaults to true
#
# [*cinder_api*]
#   (optional) Enable or not Cinder public binding.
#   Defaults to true
#
# [*glance_api*]
#   (optional) Enable or not Glance API public binding.
#   Defaults to true
#
# [*glance_registry*]
#   (optional) Enable or not Glance Registry public binding.
#   Defaults to true
#
# [*neutron_api*]
#   (optional) Enable or not Neutron public binding.
#   Defaults to true
#
# [*heat_api*]
#   (optional) Enable or not Heat public binding.
#   Defaults to true
#
# [*heat_cfn_api*]
#   (optional) Enable or not Heat CFN public binding.
#   Defaults to true
#
# [*heat_cloudwatch_api*]
#   (optional) Enable or not Heat Cloudwatch public binding.
#   Defaults to true
#
# [*nova_api*]
#   (optional) Enable or not Nova public binding.
#   Defaults to true
#
# [*ec2_api*]
#   (optional) Enable or not EC2 public binding.
#   Defaults to true
#
# [*metadata_api*]
#   (optional) Enable or not Metadata public binding.
#   Defaults to true
#
# [*keystone_api*]
#   (optional) Enable or not Keystone public binding.
#   Defaults to true
#
# [*keystone_api_admin*]
#   (optional) Enable or not Keystone admin binding.
#   Defaults to true
#
# [*keystone_api_internal*]
#   (optional) Enable or not Keystone internal binding.
#   Defaults to true
#
# [*cinder_api_internal*]
#   (optional) Enable or not Cinder internal binding.
#   Defaults to true
#
# [*ceilometer_api_internal*]
#   (optional) Enable or not Ceilometer internal binding.
#   Defaults to true
#
# [*glance_api_internal*]
#   (optional) Enable or not Glance API internal binding.
#   Defaults to true
#
# [*glance_registry_internal*]
#   (optional) Enable or not Glance Registry internal binding.
#   Defaults to true
#
# [*nova_api_internal*]
#   (optional) Enable or not Nova internal binding.
#   Defaults to true
#
# [*ec2_api_internal*]
#   (optional) Enable or not EC2 internal binding.
#   Defaults to true
#
# [*neutron_api_internal*]
#   (optional) Enable or not Neutron internal binding.
#   Defaults to true
#
# [*swift_api_internal*]
#   (optional) Enable or not Swift internal binding.
#   Defaults to true
#
# [*heat_api_internal*]
#   (optional) Enable or not Heat internal binding.
#   Defaults to true
#
# [*heat_cfn_api_internal*]
#   (optional) Enable or not Heat CFN internal binding.
#   Defaults to true
#
# [*heat_cloudwatch_api_internal*]
#   (optional) Enable or not Heat Cloudwatch internal binding.
#   Defaults to true
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
  $keystone_api                     = true,
  $swift_api_internal               = true,
  $ceilometer_api_internal          = true,
  $cinder_api_internal              = true,
  $glance_api_internal              = true,
  $glance_registry_internal         = true,
  $neutron_api_internal             = true,
  $heat_api_internal                = true,
  $heat_cfn_api_internal            = true,
  $heat_cloudwatch_api_internal     = true,
  $nova_api_internal                = true,
  $ec2_api_internal                 = true,
  $metadata_api_internal            = true,
  $keystone_api_internal            = true,
  $keystone_api_admin               = true,
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
  $ks_ceilometer_internal_port      = 8777,
  $ks_ceilometer_public_port        = 8777,
  $ks_cinder_internal_port          = 8776,
  $ks_cinder_public_port            = 8776,
  $ks_ec2_internal_port             = 8773,
  $ks_ec2_public_port               = 8773,
  $ks_glance_api_internal_port      = 9292,
  $ks_glance_api_public_port        = 9292,
  $ks_glance_registry_internal_port = 9191,
  $ks_glance_registry_public_port   = 9191,
  $ks_heat_cfn_internal_port        = 8000,
  $ks_heat_cfn_public_port          = 8000,
  $ks_heat_cloudwatch_internal_port = 8003,
  $ks_heat_cloudwatch_public_port   = 8003,
  $ks_heat_internal_port            = 8004,
  $ks_heat_public_port              = 8004,
  $ks_keystone_admin_port           = 35357,
  $ks_keystone_internal_port        = 5000,
  $ks_keystone_public_port          = 5000,
  $ks_metadata_internal_port        = 8775,
  $ks_metadata_public_port          = 8775,
  $ks_neutron_internal_port         = 9696,
  $ks_neutron_public_port           = 9696,
  $ks_nova_internal_port            = 8774,
  $ks_nova_public_port              = 8774,
  $ks_swift_internal_port           = 8080,
  $ks_swift_public_port             = 8080,
  $horizon_port                     = 80,
  $spice_port                       = 6082,
  $vip_public_ip                    = '127.0.0.2',
  $vip_internal_ip                  = false,
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

  # Fail if OpenStack and Galera VIP are  not in the VIP list
  if $vip_public_ip and !($vip_public_ip in $keepalived_public_ipvs_real) {
    fail('vip_public_ip should be part of keepalived_public_ipvs.')
  }
  if $vip_internal_ip and !($vip_internal_ip in $keepalived_internal_ipvs) {
    fail('vip_internal_ip should be part of keepalived_internal_ipvs.')
  }
  if $galera_ip and !(($galera_ip in $keepalived_public_ipvs_real) or ($galera_ip in $keepalived_internal_ipvs)) {
    fail('galera_ip should be part of keepalived_public_ipvs or keepalived_internal_ipvs.')
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
  if $keystone_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'keystone_api_internal_cluster':
        ports     => $ks_keystone_internal_port,
        listen_ip => $vip_internal_ip;
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
  if $swift_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'swift_api_internal_cluster':
        ports     => $ks_swift_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $nova_api {
    cloud::loadbalancer::listen_http{
      'nova_api_cluster':
        ports     => $ks_nova_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $nova_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'nova_api_internal_cluster':
        ports     => $ks_nova_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $ec2_api {
    cloud::loadbalancer::listen_http{
      'ec2_api_cluster':
        ports     => $ks_ec2_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $ec2_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'ec2_api_internal_cluster':
        ports     => $ks_ec2_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $metadata_api {
    cloud::loadbalancer::listen_http{
      'metadata_api_cluster':
        ports     => $ks_metadata_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $metadata_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'metadata_api_internal_cluster':
        ports     => $ks_metadata_internal_port,
        listen_ip => $vip_internal_ip;
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
  if $glance_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'glance_api_internal_cluster':
        ports     => $ks_glance_api_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $glance_registry {
    warning('Glance Registry should not be exposed to public network.')
    cloud::loadbalancer::listen_http{
      'glance_registry_cluster':
        ports     => $ks_glance_registry_internal_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $glance_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'glance_api_internal_cluster':
        ports     => $ks_glance_api_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $neutron_api {
    cloud::loadbalancer::listen_http{
      'neutron_api_cluster':
        ports     => $ks_neutron_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $neutron_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'neutron_api_internal_cluster':
        ports     => $ks_neutron_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $cinder_api {
    cloud::loadbalancer::listen_http{
      'cinder_api_cluster':
        ports     => $ks_cinder_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $cinder_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'cinder_api_internal_cluster':
        ports     => $ks_cinder_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $ceilometer_api {
    cloud::loadbalancer::listen_http{
      'ceilometer_api_cluster':
        ports     => $ks_ceilometer_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $ceilometer_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'ceilometer_api_internal_cluster':
        ports     => $ks_ceilometer_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $heat_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cluster':
        ports     => $ks_heat_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'heat_api_internal_cluster':
        ports     => $ks_heat_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $heat_cfn_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cfn_cluster':
        ports     => $ks_heat_cfn_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_cfn_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'heat_cfn_internal_cluster':
        ports     => $ks_heat_cfn_internal_port,
        listen_ip => $vip_internal_ip;
    }
  }

  if $heat_cloudwatch_api {
    cloud::loadbalancer::listen_http{
      'heat_api_cloudwatch_cluster':
        ports     => $ks_heat_cloudwatch_public_port,
        listen_ip => $vip_public_ip;
    }
  }
  if $heat_cloudwatch_api_internal and $vip_internal_ip and $keepalived_internal_ipvs {
    cloud::loadbalancer::listen_http {
      'heat_cloudwatch_internal_cluster':
        ports     => $ks_heat_cloudwatch_internal_port,
        listen_ip => $vip_internal_ip;
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

  if ($galera_ip in $keepalived_public_ipvs_real) {
    warning('Exposing Galera cluster to public network is a security issue.')
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
