#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
# SPOF node usually installed twice, and managed by Pacemaker / Corosync
#

class privatecloud::spof(
  $debug = $os_params::debug,
) {

  # Corosync & Pacemaker
  class { 'corosync':
    enable_secauth    => false,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => $::network_eth0,
    multicast_address => '239.1.1.2',
  }

  cs_property {
    'no-quorum-policy':         value => 'ignore';
    'stonith-enabled':          value => false;
    'pe-warn-series-max':       value => 1000;
    'pe-input-series-max':      value => 1000;
    'cluster-recheck-interval': value => '5min';
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

  # Resources managed by Corosync as Active / Passive
  vcsrepo { '/usr/lib/ocf/resource.d/openstack/':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/madkiss/openstack-resource-agents',
    revision => 'master',
  }

  Package['corosync'] ->
  file { '/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central':
    source  => '/usr/lib/ocf/resource.d/openstack/ceilometer-agent-central',
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
  }

  Package['corosync'] ->
  file { '/usr/lib/ocf/resource.d/heartbeat/neutron-metadata-agent':
    source  => '/usr/lib/ocf/resource.d/openstack/neutron-metadata-agent',
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
  }

  Package['corosync'] ->
  file { '/usr/lib/ocf/resource.d/heartbeat/heat-engine':
    source  => '/usr/lib/ocf/resource.d/openstack/heat-engine',
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

  # Run OpenStack Networking Metadata service
  class { 'privatecloud::network::metadata':
    enabled => false,
  }

  # Run Heat Engine service
  class { 'privatecloud::orchestration::engine':
    enabled => false,
  }

  # Run Ceilometer Agent Central service
  class { 'privatecloud::telemetry::centralagent':
    enabled => false,
  }

}
