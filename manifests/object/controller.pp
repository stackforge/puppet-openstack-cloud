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
# Swift Proxy node
#

class privatecloud::object::controller(
  $ks_keystone_admin_host = $os_params::ks_keystone_admin_host,
  $ks_keystone_admin_port = $os_params::ks_keystone_admin_port,
  $ks_keystone_internal_host = $os_params::ks_keystone_internal_host,
  $ks_keystone_internal_port = $os_params::ks_keystone_internal_port,
  $ks_swift_dispersion_password = $os_params::ks_swift_dispersion_password,
  $ks_swift_internal_port = $os_params::ks_swift_internal_port,
  $ks_swift_password = $os_params::ks_swift_password,
  $statsd_host = $os_params::statsd_host,
  $statsd_port = $os_params::statsd_port,
  $swift_memchached = $os_params::swift_memchached
) {

  class { 'swift::proxy':
    proxy_local_net_ip => $ipaddress_eth0,
    port               => $ks_swift_internal_port,
    pipeline           => [
      #'catch_errors', 'healthcheck', 'cache', 'bulk', 'ratelimit',
      'catch_errors', 'healthcheck', 'cache', 'ratelimit',
      #'swift3', 's3token', 'container_quotas', 'account_quotas', 'tempurl',
      'swift3', 's3token', 'tempurl',
      'formpost', 'staticweb', 'ceilometer', 'authtoken', 'keystone',
      'proxy-logging', 'proxy-server'],
    account_autocreate => true,
    log_level          => 'DEBUG',
    workers            => inline_template('<%= @processorcount.to_i * 2 %>
cors_allow_origin = <%= scope.lookupvar("swift_cors_allow_origin") %>
log_statsd_host = <%= scope.lookupvar("statsd_host") %>
log_statsd_port = <%= scope.lookupvar("statsd_port") %>
log_statsd_default_sample_rate = 1
'),
  }

  class{'swift::proxy::cache':
    memcache_servers => inline_template(
      '<%= scope.lookupvar("swift_memchached").join(",") %>'),
  }
  class { 'swift::proxy::proxy-logging': }
  class { 'swift::proxy::healthcheck': }
  class { 'swift::proxy::catch_errors': }
  class { 'swift::proxy::ratelimit': }
  #class { 'swift::proxy::account_quotas': }
  #class { 'swift::proxy::container_quotas': }
  #class { 'swift::proxy::bulk': }
  class { 'swift::proxy::staticweb': }
  class { 'swift::proxy::ceilometer': }
  class { 'swift::proxy::keystone':
    operator_roles => ['admin', 'SwiftOperator', 'ResellerAdmin'],
  }

  class { 'swift::proxy::tempurl': }
  class { 'swift::proxy::formpost': }
  class { 'swift::proxy::authtoken':
    admin_password      => $ks_swift_password,
    auth_host           => $ks_keystone_admin_host,
    auth_port           => $ks_keystone_admin_port,
    delay_auth_decision => inline_template('1
cache = swift.cache')
  }
  class { 'swift::proxy::swift3':
    ensure => 'latest',
  }
  class { 'swift::proxy::s3token':
    auth_host     => $ks_keystone_admin_host,
    auth_port     => $ks_keystone_admin_port,
  }

  class { 'swift::dispersion':
    auth_url  => "http://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0
endpoint_type=internalURL",
    auth_pass => $ks_swift_dispersion_password
  }

  # Note(sileht): log file should exists to swift proxy to write to
  # the ceilometer directory
  file{'/var/log/ceilometer/swift-proxy-server.log':
    ensure => present,
    owner  => 'swift',
    group  => 'swift',
    notify => Service['swift-proxy']
  }

  Swift::Ringsync<<| |>> #~> Service["swift-proxy"]

  @@haproxy::balancermember{"${::fqdn}-swift_api":
      listening_service => 'swift_api_cluster',
      server_names      => $::hostname,
      ipaddresses       => $local_ip,
      ports             => $ks_swift_internal_port,
      options           => 'check inter 2000 rise 2 fall 5'
  }

}
