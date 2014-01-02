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
# HAproxy nodes
#

class privatecloud::loadbalancer(
  $ceilometer_api                 = true,
  $cinder_api                     = true,
  $glance_api                     = true,
  $neutron_api                    = true,
  $heat_api                       = true,
  $heat_cfn_api                   = true,
  $heat_cloudwatch_api            = true,
  $nova_api                       = true,
  $ec2_api                        = true,
  $metadata_api                   = true,
  $spice_api                      = true,
  $swift_api                      = true,
  $keystone_api_admin             = true,
  $keystone_api                   = true,
  $horizon                        = true,
  $spice                          = true,
  $haproxy_auth                   = $os_params::haproxy_auth,
  $keepalived_email               = $os_params::keepalived_email,
  $keepalived_interface           = 'eth1',
  $keepalived_ipvs                = [],
  $keepalived_localhost_ip        = $::ipaddress_eth1,
  $keepalived_smtp                = $os_params::keepalived_smtp,
  $ks_cinder_ceilometer_port      = $os_params::ks_ceilometer_public_port,
  $ks_cinder_public_port          = $os_params::ks_cinder_public_port,
  $ks_ceilometer_public_port      = $os_params::ks_ceilometer_public_port,
  $ks_ec2_public_port             = $os_params::ks_ec2_public_port,
  $ks_glance_public_port          = $os_params::ks_glance_public_port,
  $ks_heat_public_port            = $os_params::ks_heat_public_port,
  $ks_heat_cfn_public_port        = $os_params::ks_heat_cfn_public_port,
  $ks_heat_cloudwatch_public_port = $os_params::ks_heat_cloudwatch_public_port,
  $ks_keystone_admin_port         = $os_params::ks_keystone_admin_port,
  $ks_keystone_public_port        = $os_params::ks_keystone_public_port,
  $ks_metadata_public_port        = $os_params::ks_metadata_public_port,
  $ks_neutron_public_port         = $os_params::ks_neutron_public_port,
  $ks_nova_public_port            = $os_params::ks_nova_public_port,
  $ks_swift_public_port           = $os_params::ks_swift_public_port,
  $horizon_port                   = $os_params::horizon_port,
  $spice_port                     = $os_params::spice_port,
){

  class { 'haproxy': }

  class { 'keepalived':
    notification_email_to => $keepalived_email,
    smtp_server           => $keepalived_smtp,
  }

  keepalived::vrrp_script { 'haproxy':
    name_is_process => true
  }

  keepalived::instance { '1':
    interface         => $keepalived_interface,
    virtual_ips       => split(join(flatten([$keepalived_ipvs, ['']]), " dev ${keepalived_interface},"), ','),
    state             => 'MASTER',
    track_script      => ['haproxy'],
    priority          => 50,
  }

  $monitors_data = inline_template('
<%- if @swift_api -%>
acl swift_api_dead nbsrv(swift_api_cluster) lt 1
monitor fail if swift_api_dead
<%- end -%>
<%- if @keystone_api -%>
acl keystone_api_dead nbsrv(keystone_api_cluster) lt 1
monitor fail if keystone_api_dead
<% end -%>
<%- if @galera -%>
acl galera_dead nbsrv(galera_cluster) lt 1
monitor fail if galera_dead
<%- end -%>
<%- if @neutron_api -%>
acl neutron_api_dead nbsrv(neutron_api_cluster) lt 1
monitor fail if neutron_api_dead
<%- end -%>
<%- if @cinder_api -%>
acl cinder_api_dead nbsrv(cinder_api_cluster) lt 1
monitor fail if cinder_api_dead
<%- end -%>
<%- if @nova_api -%>
acl nova_api_dead nbsrv(nova_api_cluster) lt 1
monitor fail if nova_api_dead
<%- end -%>
<%- if @nova_ec2 -%>
acl nova_ec2_dead nbsrv(nova_ec2_cluster) lt 1
monitor fail if nova_ec2_dead
<%- end -%>
<%- if @nova_metadata -%>
acl nova_metadata_dead nbsrv(nova_metadata_cluster) lt 1
monitor fail if nova_metadata_dead
<%- end -%>
<%- if @spice -%>
acl spice_dead nbsrv(spice_cluster) lt 1
monitor fail if spice_dead
<%- end -%>
<%- if @glance_api -%>
acl nova_api_dead nbsrv(glance_api_cluster) lt 1
monitor fail if nova_api_dead
<%- end -%>
<%- if @ceilometer_api -%>
acl ceilometer_api_dead nbsrv(ceilometer_api_cluster) lt 1
monitor fail if ceilometer_api_dead
<%- end -%>
<%- if @heat_api -%>
acl heat_api_dead nbsrv(heat_api_cluster) lt 1
monitor fail if heat_api_dead
<%- end -%>
<%- if @heat_cfn_api -%>
acl heat_api_cfn_dead nbsrv(heat_api_cfn_cluster) lt 1
monitor fail if heat_api_cfn_dead
<%- end -%>
<%- if @heat_cloudwatch_api -%>
acl heat_api_cloudwatch_dead nbsrv(heat_api_cloudwatch_cluster) lt 1
monitor fail if heat_api_cloudwatch_dead
<%- end -%>
<%- if @horizon -%>
acl horizon_dead nbsrv(horizon_cluster) lt 1
monitor fail if horizon_dead
<%- end -%>
')

  file{'/etc/logrotate.d/haproxy':
    content => "
  /var/log/haproxy.log
{
        rotate 7
        daily
        missingok
        notifempty
        delaycompress
        compress
        postrotate
        endscript
}
"
  }

  haproxy::listen { 'monitor':
    ipaddress => $keepalived_localhost_ip,
    ports     => '9300',
    options   => {
      'mode'        => 'http',
      'monitor-uri' => '/status',
      'stats'       => ['enable','uri     /admin','realm   Haproxy\ Statistics',"auth    ${haproxy_auth}", 'refresh 5s' ],
      ''            => $monitors_data,
    }
  }

  if $keystone_api {
    privatecloud::loadbalancer::listen_http {
      'keystone_api_cluster':
        ports     => $ks_keystone_public_port,
        listen_ip => $keepalived_localhost_ip;
      'keystone_api_admin_cluster':
        ports     => $ks_keystone_admin_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $swift_api {
    privatecloud::loadbalancer::listen_http{
      'swift_api_cluster':
        ports     => $ks_swift_public_port,
        httpchk   => 'httpchk /healthcheck',
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $nova_api {
    privatecloud::loadbalancer::listen_http{
      'nova_api_cluster':
        ports     => $ks_nova_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $ec2_api {
    privatecloud::loadbalancer::listen_http{
      'ec2_api_cluster':
        ports     => $ks_ec2_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $metadata_api {
    privatecloud::loadbalancer::listen_http{
      'metadata_api_cluster':
        ports     => $ks_metadata_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $spice {
    privatecloud::loadbalancer::listen_http{
      'spice_cluster':
        ports     => $spice_port,
        listen_ip => $keepalived_localhost_ip,
        httpchk   => 'httpchk GET /';
    }
  }
  if $glance_api {
    privatecloud::loadbalancer::listen_http{
      'glance_api_cluster':
        ports     => $ks_glance_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $neutron_api {
    privatecloud::loadbalancer::listen_http{
      'neutron_api_cluster':
        ports     => $ks_neutron_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $cinder_api {
    privatecloud::loadbalancer::listen_http{
      'cinder_api_cluster':
        ports     => $ks_cinder_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $ceilometer_api {
    privatecloud::loadbalancer::listen_http{
      'ceilometer_api_cluster':
        ports     => $ks_ceilometer_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $heat_api {
    privatecloud::loadbalancer::listen_http{
      'heat_api_cluster':
        ports     => $ks_heat_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $heat_cfn_api {
    privatecloud::loadbalancer::listen_http{
      'heat_api_cfn_cluster':
        ports     => $ks_heat_cfn_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $heat_cloudwatch_api {
    privatecloud::loadbalancer::listen_http{
      'heat_api_cloudwatch_cluster':
        ports     => $ks_heat_cloudwatch_public_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }
  if $horizon {
    privatecloud::loadbalancer::listen_http{
      'horizon_cluster':
        ports     => $horizon_port,
        listen_ip => $keepalived_localhost_ip;
    }
  }

  haproxy::listen { 'galera_cluster':
    ipaddress          => $keepalived_localhost_ip,
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
