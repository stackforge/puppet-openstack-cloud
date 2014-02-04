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
# == Class: cloud::spof
#
# Install all SPOF services in active / passive with Pacemaker / Corosync
#
# === Parameters:
#
# [*cluster_ip*]
#   (optional) Interface used by Corosync to send multicast traffic
#   Default to params.
#
# [*multicast_address*]
#   (optionnal) IP address used to send multicast traffic
#   Default to '239.1.1.2'.
#

class cloud::spof(
  $cluster_ip        = $os_params::cluster_ip,
  $multicast_address = '239.1.1.2'
) {

  class { 'corosync':
    enable_secauth    => false,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => $cluster_ip,
    multicast_address => $multicast_address
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

  Package['corosync'] ->
  cs_property {
    'no-quorum-policy':         value => 'ignore';
    'stonith-enabled':          value => false;
    'pe-warn-series-max':       value => 1000;
    'pe-input-series-max':      value => 1000;
    'cluster-recheck-interval': value => '5min';
  } ->
  file { '/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central':
    source  => 'puppet:///modules/cloud/heartbeat/ceilometer-agent-central',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ->
  cs_primitive { 'ceilometer-agent-central':
    primitive_class => 'ocf',
    primitive_type  => 'ceilometer-agent-central',
    provided_by     => 'heartbeat',
    operations      => {
      'monitor' => {
        interval => '10s',
        timeout  => '30s'
      },
      'start'   => {
        interval => '0',
        timeout  => '30s',
        on-fail  => 'restart'
      }
    }
  } ->
  file { '/usr/lib/ocf/resource.d/heartbeat/neutron-metadata-agent':
    source  => 'puppet:///modules/cloud/heartbeat/neutron-metadata-agent',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ->
  cs_primitive { 'neutron-metadata-agent':
    primitive_class => 'ocf',
    primitive_type  => 'neutron-metadata-agent',
    provided_by     => 'heartbeat',
    operations      => {
      'monitor' => {
        interval  => '10s',
        timeout   => '30s'
      },
      'start'   => {
        interval  => '0',
        timeout   => '30s',
        on-fail   => 'restart'
      }
    }
  } ->
  file { '/usr/lib/ocf/resource.d/heartbeat/heat-engine':
    source  => 'puppet:///modules/cloud/heartbeat/heat-engine',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ->
  cs_primitive { 'heat-engine':
    primitive_class => 'ocf',
    primitive_type  => 'heat-engine',
    provided_by     => 'heartbeat',
    operations      => {
      'monitor' => {
        interval => '10s',
        timeout  => '30s'
      },
      'start'   => {
        interval => '0',
        timeout  => '30s',
        on-fail  => 'restart'
      }
    }
  }

  # Run OpenStack SPOF service and disable them since they will be managed by Corosync.
  class { 'cloud::network::metadata':
    enabled => false,
  }

  class { 'cloud::orchestration::engine':
    enabled => false,
  }

  class { 'cloud::telemetry::centralagent':
    enabled => false,
  }

}
