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

# HAproxy nodes


class os_role_loadbalancer(
  $keepalived_localhost_ip = $ipaddress_eth0,
  $keepalived_interface = 'eth0',
  $keepalived_ipvs = [],
  $swift_api = false,
  $keystone_api = false,
  $keystone_api_admin = false,
  $compute_api = false,
  $galera = false,
  $neutron_api = false,
  $ceilometer_api = false,
  $horizon = false,
  $heat_api = false,
  $local_ip = $ipaddress_eth0,
){

  class { 'haproxy': }
  class { 'keepalived':
    notification_email_to => [ $os_params::keepalived_email ],
    smtp_server           => $os_params::keepalived_smtp,
  }


  $monitors_data = inline_template('
<%- if @swift_api -%>
acl swift_api_dead nbsrv(swift_api_cluster) lt 1
monitor fail if swift_api_dead
<%- end -%>
<%- if @keystone_api -%>
acl keystone_api_dead nbsrv(keystone_api_cluster) lt 1
monitor fail if keystone_dead
<% end -%>
<%- if @galera -%>
acl galera_dead nbsrv(galera_cluster) lt 1
monitor fail if galera_dead
<%- end -%>
<%- if @neutron_api -%>
acl neutron_api_dead nbsrv(neutron_api_cluster) lt 1
monitor fail if neutron_api_dead
<%- end -%>
<%- if @compute_api -%>
acl compute_api_dead nbsrv(compute_api_cluster) lt 1
monitor fail if compute_api_dead
<%- end -%>
<%- if @ceilometer_api -%>
acl ceilometer_api_dead nbsrv(ceilometer_api_cluster) lt 1
monitor fail if ceilometer_api_dead
<%- end -%>
<%- if @heat_api -%>
acl heat_api_dead nbsrv(heat_api_cluster) lt 1
monitor fail if heat_api_dead
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
    ipaddress => '0.0.0.0',
    ports     => '9300',
    options   => {
      'mode'        => 'http',
      'monitor-uri' => '/status',
      'stats'       => ['enable','uri     /admin','realm   Haproxy\ Statistics',"auth    ${os_params::haproxy_auth}", 'refresh 5s' ],
      ''            => $monitors_data,
    }
  }

  define os_haproxy_listen_http($ports, $httpchk = 'httpchk'){
    haproxy::listen { $name:
      ipaddress => '0.0.0.0',
      ports     => $ports,
      options   => {
        'mode'        => 'http',
        'balance'     => 'roundrobin',
        'option'      => ['tcpka', 'tcplog', $httpchk],
        'http-check'  => 'expect ! rstatus ^5',
      }
    }
  }

  define os_compute_haproxy_listen_http{
    if $name == '6082' { # spice doesn't support OPTIONS
      $httpchk = 'httpchk GET /'
    } else {
      $httpchk = 'httpchk'
    }
    os_haproxy_listen_http{"compute_api_cluster_${name}":
      httpchk => $httpchk,
      ports   => $name
    }
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

  if $swift {
    os_haproxy_listen_http{ 'swift_api_cluster': ports => $os_params::swift_port, httpchk => 'httpchk /healthcheck'  }
  }
  if $keystone {
    os_haproxy_listen_http { 'keystone_api_cluster': ports => $os_params::keystone_port }
    os_haproxy_listen_http { 'keystone_api_admin_cluster': ports => $os_params::keystone_admin_port }
  }
  if $compute_api {
    os_compute_haproxy_listen_http{$os_params::compute_api_ports: }
  }
  if $neutron_server {
    os_haproxy_listen_http{'neutron_api_cluster': ports => $os_params::neutron_port }
  }
  if $ceilometer_api {
    os_haproxy_listen_http{'ceilometer_api_cluster': ports => $os_params::ceilometer_port }
  }
  if $horizon {
    os_haproxy_listen_http{'horizon_cluster': ports => $os_params::horizon_port }
  }
  if $heat_api {
    os_haproxy_listen_http{'heat_api_cluster': ports => $os_params::heat_port }
  }

  if $galera {
    haproxy::listen { 'galera_cluster':
      ipaddress          => '0.0.0.0',
      ports              => 3306,
      options            => {
        'mode'           => 'tcp',
        'balance'        => 'roundrobin',
        'option'         => ['tcpka', 'tcplog', 'httpchk'],  # httpchk mandatory expect 200 on port 9000
        'timeout client' => '400s',
        'timeout server' => '400s',
      }
    }
  }

}
