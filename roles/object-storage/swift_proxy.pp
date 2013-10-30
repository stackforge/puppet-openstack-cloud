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

# Swift Proxy node

class os_role_swift_proxy(
    $local_ip = $ipaddress_eth0,
) inherits os_role_swift {

  class { 'memcached':
    listen_ip  => $local_ip,
    max_memory => '60%',
  }

  class { 'swift::proxy':
    proxy_local_net_ip => $local_ip,
    port => $os_params::swift_port,
    pipeline           => [
      'catch_errors', 'healthcheck', 'cache', 'ratelimit',
      'swift3', 's3token', 'tempurl', 'formpost', 'authtoken',
      'keystone', 'proxy-logging', 'proxy-server', 'staticweb'],
    account_autocreate => true,
    log_level          => 'DEBUG',
    workers            => inline_template('<%= processorcount.to_i * 2 %>
cors_allow_origin = <%= scope.lookupvar("os_params::swift_cors_allow_origin") %>
log_statsd_host = <%= scope.lookupvar("os_params::statsd_host") %>
log_statsd_port = <%= scope.lookupvar("os_params::statsd_port") %>
log_statsd_default_sample_rate = 1
'),
  }
  class{'swift::proxy::cache':
    memcache_servers => inline_template(
      '<%= scope.lookupvar("os_params::swift_memchached").join(",") %>'),
  }

  class { 'swift::proxy::proxy-logging': }
  class { 'swift::proxy::healthcheck': }
  class { 'swift::proxy::catch_errors': }
  class { 'swift::proxy::ratelimit': }
  class { 'swift::proxy::staticweb': }

  class { 'swift::proxy::keystone':
    operator_roles => ['admin', 'SwiftOperator', 'ResellerAdmin'],
  }

  class { 'swift::proxy::tempurl': }
  class { 'swift::proxy::formpost': }
  class { 'swift::proxy::authtoken':
    admin_password      => $os_params::ks_swift_password,
    auth_host           => $os_params::ks_keystone_admin_host,
    auth_port           => $os_params::keystone_admin_port,
    delay_auth_decision => inline_template('1
cache = swift.cache')
  }

  class { 'swift::proxy::swift3': 
    ensure => 'latest',
  }
  class { 'swift::proxy::s3token':
    auth_host     => $os_params::ks_keystone_admin_host,
    auth_port     => $os_params::keystone_admin_port,
  }

  class { 'swift::dispersion': 
    auth_url  => "http://${os_params::ks_keystone_internal_host}:${os_params::keystone_port}/v2.0
endpoint_type=internalURL",
    auth_pass => $os_params::ks_swift_dispersion_password
  }

  # Note(sileht): log file should exists to swift proxy to write to
  # the ceilometer directory
  file{"/var/log/ceilometer/swift-proxy-server.log":
    ensure => present,
    owner  => 'swift',
    group  => 'swift',
    notify => Service['swift-proxy']
  }

  Swift::Ringsync<<| |>> #~> Service["swift-proxy"]

}
