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

class os_identity_controller (
  $local_ip = $ipaddress_eth0,
){

# Configure Keystone
  class { 'keystone':
    enabled          => false,
    admin_token      => $::os_params::ks_admin_token,
    compute_port     => '8774',
    verbose          => true,
    debug            => true,
    sql_connection   => "mysql://${::os_params::keystone_db_user}:${::os_params::keystone_db_password}@${::os_params::keystone_db_host}/keystone",
    idle_timeout     => 60,
    token_format     => 'UUID',
    memcache_servers => $::os_params::keystone_memcached,
    token_driver     => "keystone.token.backends.memcache.Token",
    use_syslog       => true,
    log_facility     => 'LOG_LOCAL0',
  }

  keystone_config {
    'token/expiration': value => '86400';
    'ec2/driver':       value => 'keystone.contrib.ec2.backends.sql.Ec2';
  }


# Keystone Endpoints + Users
  class { 'keystone::roles::admin':
    email        => $::os_params::ks_admin_email,
    password     => $::os_params::ks_admin_password,
    admin_tenant => $::os_params::ks_admin_tenant,
  }

  keystone_role { $::os_params::identity_roles_addons: ensure => present }

  class {'keystone::endpoint':
    public_address   => $::os_params::ks_keystone_public_host,
    admin_address    => $::os_params::ks_keystone_admin_host,
    internal_address => $::os_params::ks_keystone_internal_host,
    public_port      => $::os_params::ks_keystone_public_port,
    admin_port       => $::os_params::ks_keystone_admin_port,
    internal_port    => $::os_params::ks_keystone_internal_port,
    region           => $::os_params::region,
    public_protocol  => $::os_params::ks_keystone_public_proto
  }

  keystone_config { 'ssl/enable': ensure => absent }

  include 'apache'

  class {'keystone::wsgi::apache':
    ssl         => false,
    public_port => $::os_params::ks_keystone_public_port,
    admin_port  => $::os_params::ks_keystone_admin_port,
  }

  class {'swift::keystone::auth':
    password         => $::os_params::ks_swift_password,
    address          => $::os_params::ks_swift_internal_host,
    port             => $::os_params::swift_port,
    public_address   => $::os_params::ks_swift_public_host,
    public_protocol  => $::os_params::ks_swift_public_proto,
    region           => $::os_params::region,
    public_port      => $::os_params::ks_swift_public_port
  }

  class {'ceilometer::keystone::auth':
    password         => $::os_params::ks_ceilometer_password,
    public_address   => $::os_params::ks_ceilometer_public_host,
    admin_address    => $::os_params::ks_ceilometer_admin_host,
    internal_address => $::os_params::ks_ceilometer_internal_host,
    public_protocol  => $::os_params::ks_ceilometer_public_proto,
    region           => $::os_params::region,
    port             => $::os_params::ks_internal_ceilometer_port,
  }

  class {'swift::keystone::dispersion':
    auth_pass => $::os_params::ks_swift_dispersion_password
  }

  class { 'nova::keystone::auth':
    password         => $::os_params::ks_nova_password,
    public_address   => $::os_params::ks_nova_public_host,
    admin_address    => $::os_params::ks_nova_admin_host,
    internal_address => $::os_params::ks_nova_internal_host,
    public_protocol  => $::os_params::ks_nova_public_proto,
    cinder           => true,
  }

  class { 'neutron::keystone::auth':
    password         => $::os_params::ks_neutron_password,
    public_address   => $::os_params::ks_neutron_public_host,
    admin_address    => $::os_params::ks_neutron_admin_host,
    internal_address => $::os_params::ks_neutron_internal_host,
    public_protocol  => $::os_params::ks_neutron_public_proto,
  }

  class { 'cinder::keystone::auth':
    password         => $::os_params::ks_cinder_password,
    public_address   => $::os_params::ks_cinder_public_host,
    admin_address    => $::os_params::ks_cinder_admin_host,
    internal_address => $::os_params::ks_cinder_internal_host,
    public_protocol  => $::os_params::ks_cinder_public_proto,
  }

  class { 'glance::keystone::auth':
    password         => $::os_params::ks_glance_password,
    public_address   => $::os_params::ks_glance_public_host,
    admin_address    => $::os_params::ks_glance_admin_host,
    internal_address => $::os_params::ks_glance_internal_host,
    public_protocol  => $::os_params::ks_glance_public_proto,
  }

  class { 'heat::keystone::auth':
    password         => $::os_params::ks_heat_password,
    public_address   => $::os_params::ks_heat_public_host,
    admin_address    => $::os_params::ks_heat_admin_host,
    internal_address => $::os_params::ks_heat_internal_host,
    public_protocol  => $::os_params::ks_heat_public_proto,
  }

# Workaround for error "HTTPConnectionPool(host='127.0.0.1', port=35357): Max retries exceeded with url"
# In fact, when keystone finish to start but admin port isn't already usable, so wait a bit
exec{'wait-keystone': command => '/bin/sleep 5' }
Service['keystone'] -> Exec['wait-keystone']
Exec['wait-keystone'] -> Keystone_tenant <| |>
Exec['wait-keystone'] -> Keystone_user <| |>
Exec['wait-keystone'] -> Keystone_role  <| |>
Exec['wait-keystone'] -> Keystone_service <| |>
Exec['wait-keystone'] -> Keystone_user_role <| |>
Exec['wait-keystone'] -> Keystone_endpoint <| |>

}
