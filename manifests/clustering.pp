#
# Copyright (C) 2015 Red Hat Inc.
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

# == Class: cloud::clustering
#
# Initialize Pacemaker / Corosync cluster
#
# === Parameters:
#
# [*cluster_members*]
#   (required) Array of hostnames of cluster nodes
#
# [*cluster_ip*]
#   (optional) IP address used by Corosync to send multicast traffic
#   Defaults to '127.0.0.1'
#
# [*cluster_auth*]
#   (optional) Controls corosync's ability to authenticate and encrypt
#   multicast messages.
#   Defaults to false
#
# [*cluster_authkey*]
#   (optional) Specifies the path to the CA which is used to sign Corosync's
#   certificate.
#   Defaults to '/var/lib/puppet/ssl/certs/ca.pem'
#
# [*cluster_recheck_interval*]
#   (optional) This tells the cluster to periodically recalculate the ideal
#   state of the cluster.
#   Defaults to 5min
#
# [*pe_warn_series_max*]
#   (optional) The number of PE inputs resulting in WARNINGs to save. Used when
#   reporting problems.
#   Defaults to 1000
#
# [*pe_input_series_max*]
#   (optional) The number of "normal" PE inputs to save. Used when reporting
#   problems.
#   Defaults to 1000
#
# [*pe_error_series_max*]
#   (optional) The number of PE inputs resulting in ERRORs to save. Used when
#   reporting problems.
#   Defaults to 1000
#
# [*multicast_address*]
#   (optionnal) IP address used to send multicast traffic
#   Defaults to '239.192.168.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be a hash.
#   Default to {}
#
class cloud::clustering (
  $cluster_members,
  $cluster_ip               = '127.0.0.1',
  $cluster_auth             = false,
  $cluster_authkey          = '/var/lib/puppet/ssl/certs/ca.pem',
  $cluster_recheck_interval = '5min',
  $pe_warn_series_max       = 1000,
  $pe_input_series_max      = 1000,
  $pe_error_series_max      = 1000,
  $multicast_address        = '239.192.168.1',
  $firewall_settings        = {},
) {

  if $::osfamily == 'RedHat' {
    $packages = ['corosync', 'pacemaker', 'pcs']
    $set_votequorum = true

    Service['pcsd'] -> Cs_property<||>
    Service['pacemaker'] -> Cs_property<||>

    service { 'pcsd':
      ensure  => 'running',
      enable  => true,
      require => Class['corosync'],
    } -> service { 'pacemaker':
      ensure  => 'running',
      enable  => true,
      require => Class['corosync'],
    }
  } else {
    $packages = ['corosync', 'pacemaker']
    $set_votequorum = false
  }

  class { 'corosync':
    enable_secauth    => $cluster_auth,
    authkey           => $cluster_authkey,
    bind_address      => $cluster_ip,
    multicast_address => $multicast_address,
    packages          => $packages,
    set_votequorum    => $set_votequorum,
    quorum_members    => $cluster_members,
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

  Package['corosync'] -> Cs_property<||>
  cs_property {
    # Doesn't work with pcs yet (Fedora20), but will work in future:
    # -> https://github.com/feist/pcs/issues/20
    #'cluster-recheck-interval': value => $cluster_recheck_interval;
    'pe-warn-series-max':       value => $pe_warn_series_max;
    'pe-input-series-max':      value => $pe_input_series_max;
    'pe-error-series-max':      value => $pe_error_series_max;
  }
  if count($cluster_members) < 3 {
    # stonith is not required for less then 3 nodes, also quorum can be hold
    # only with three or more nodes
    cs_property {
      'no-quorum-policy': value => 'ignore';
      'stonith-enabled':  value => 'false';
    }
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow vrrp access':
      port   => undef,
      proto  => 'vrrp',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow corosync tcp access':
      port   => ['2224', '3121', '21064'],
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow corosync udp access':
      port   => ['5404', '5405'],
      proto  => 'udp',
      extras => $firewall_settings,
    }
  }
}
