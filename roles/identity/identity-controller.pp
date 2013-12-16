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
# Identity controller
#

class os_identity_controller (
  $identity_roles_addons        = $os_params::identity_roles_addons,
  $keystone_db_host             = $os_params::keystone_db_host,
  $keystone_db_password         = $os_params::keystone_db_password,
  $keystone_db_user             = $os_params::keystone_db_user,
  $keystone_memcached           = $os_params::keystone_memcached,
  $ks_admin_email               = $os_params::ks_admin_email,
  $ks_admin_password            = $os_params::ks_admin_password,
  $ks_admin_tenant              = $os_params::ks_admin_tenant,
  $ks_admin_token               = $os_params::ks_admin_token,
  $ks_ceilometer_admin_host     = $os_params::ks_ceilometer_admin_host,
  $ks_ceilometer_internal_host  = $os_params::ks_ceilometer_internal_host,
  $ks_ceilometer_password       = $os_params::ks_ceilometer_password,
  $ks_ceilometer_public_host    = $os_params::ks_ceilometer_public_host,
  $ks_ceilometer_public_port    = $os_params::ks_ceilometer_public_port,
  $ks_ceilometer_public_proto   = $os_params::ks_ceilometer_public_proto,
  $ks_cinder_admin_host         = $os_params::ks_cinder_admin_host,
  $ks_cinder_internal_host      = $os_params::ks_cinder_internal_host,
  $ks_cinder_password           = $os_params::ks_cinder_password,
  $ks_cinder_public_host        = $os_params::ks_cinder_public_host,
  $ks_cinder_public_proto       = $os_params::ks_cinder_public_proto,
  $ks_glance_admin_host         = $os_params::ks_glance_admin_host,
  $ks_glance_internal_host      = $os_params::ks_glance_internal_host,
  $ks_glance_password           = $os_params::ks_glance_password,
  $ks_glance_public_host        = $os_params::ks_glance_public_host,
  $ks_glance_public_proto       = $os_params::ks_glance_public_proto,
  $ks_heat_admin_host           = $os_params::ks_heat_admin_host,
  $ks_heat_internal_host        = $os_params::ks_heat_internal_host,
  $ks_heat_password             = $os_params::ks_heat_password,
  $ks_heat_public_host          = $os_params::ks_heat_public_host,
  $ks_heat_public_proto         = $os_params::ks_heat_public_proto,
  $ks_internal_ceilometer_port  = $os_params::ks_internal_ceilometer_port,
  $ks_keystone_admin_host       = $os_params::ks_keystone_admin_host,
  $ks_keystone_admin_port       = $os_params::ks_keystone_admin_port,
  $ks_keystone_internal_host    = $os_params::ks_keystone_internal_host,
  $ks_keystone_internal_port    = $os_params::ks_keystone_internal_port,
  $ks_keystone_public_host      = $os_params::ks_keystone_public_host,
  $ks_keystone_public_port      = $os_params::ks_keystone_public_port,
  $ks_keystone_public_proto     = $os_params::ks_keystone_public_proto,
  $ks_neutron_admin_host        = $os_params::ks_neutron_admin_host,
  $ks_neutron_internal_host     = $os_params::ks_neutron_internal_host,
  $ks_neutron_password          = $os_params::ks_neutron_password,
  $ks_neutron_public_host       = $os_params::ks_neutron_public_host,
  $ks_neutron_public_proto      = $os_params::ks_neutron_public_proto,
  $ks_nova_admin_host           = $os_params::ks_nova_admin_host,
  $ks_nova_internal_host        = $os_params::ks_nova_internal_host,
  $ks_nova_password             = $os_params::ks_nova_password,
  $ks_nova_public_host          = $os_params::ks_nova_public_host,
  $ks_nova_public_proto         = $os_params::ks_nova_public_proto,
  $ks_swift_dispersion_password = $os_params::ks_swift_dispersion_password,
  $ks_swift_internal_host       = $os_params::ks_swift_internal_host,
  $ks_swift_internal_port       = $os_params::ks_swift_internal_port,
  $ks_swift_password            = $os_params::ks_swift_password,
  $ks_swift_public_host         = $os_params::ks_swift_public_host,
  $ks_swift_public_port         = $os_params::ks_swift_public_port,
  $ks_swift_public_proto        = $os_params::ks_swift_public_proto,
  $local_ip                     = $ipaddress_eth0,
  $region                       = $os_params::region,
  $verbose                      = $os_params::verbose,
  $debug                        = $os_params::debug
){

  $encoded_user     = uriescape($keystone_db_user)
  $encoded_password = uriescape($keystone_db_password)

# Configure Keystone
  class { 'keystone':
    enabled          => false,
    admin_token      => $ks_admin_token,
    compute_port     => '8774',
    debug            => $debug,
    idle_timeout     => 60,
    log_facility     => 'LOG_LOCAL0',
    memcache_servers => $keystone_memcached,
    sql_connection   => "mysql://${encoded_user}:${encoded_password}@${keystone_db_host}/keystone",
    token_driver     => 'keystone.token.backends.memcache.Token',
    token_format     => 'UUID',
    use_syslog       => true,
    verbose          => $verbose,
  }

  keystone_config {
    'token/expiration': value => '86400';
    'ec2/driver':       value => 'keystone.contrib.ec2.backends.sql.Ec2';
  }


# Keystone Endpoints + Users
  class { 'keystone::roles::admin':
    email        => $ks_admin_email,
    password     => $ks_admin_password,
    admin_tenant => $ks_admin_tenant,
  }

  keystone_role { $identity_roles_addons: ensure => present }

  class {'keystone::endpoint':
    admin_address    => $ks_keystone_admin_host,
    admin_port       => $ks_keystone_admin_port,
    internal_address => $ks_keystone_internal_host,
    internal_port    => $ks_keystone_internal_port,
    public_address   => $ks_keystone_public_host,
    public_port      => $ks_keystone_public_port,
    public_protocol  => $ks_keystone_public_proto,
    region           => $region,
  }

  keystone_config { 'ssl/enable': ensure => absent }

  include 'apache'

  class {'keystone::wsgi::apache':
    admin_port  => $ks_keystone_admin_port,
    public_port => $ks_keystone_public_port,
    ssl         => false,
  }

  class {'swift::keystone::auth':
    address          => $ks_swift_internal_host,
    password         => $ks_swift_password,
    port             => $ks_swift_internal_port,
    public_address   => $ks_swift_public_host,
    public_port      => $ks_swift_public_port,
    public_protocol  => $ks_swift_public_proto,
    region           => $region,
  }

  class {'ceilometer::keystone::auth':
    admin_address    => $ks_ceilometer_admin_host,
    internal_address => $ks_ceilometer_internal_host,
    password         => $ks_ceilometer_password,
    port             => $ks_internal_ceilometer_port,
    public_address   => $ks_ceilometer_public_host,
    public_protocol  => $ks_ceilometer_public_proto,
    region           => $region,
  }

  class {'swift::keystone::dispersion':
    auth_pass => $ks_swift_dispersion_password
  }

  class { 'nova::keystone::auth':
    admin_address    => $ks_nova_admin_host,
    cinder           => true,
    internal_address => $ks_nova_internal_host,
    password         => $ks_nova_password,
    public_address   => $ks_nova_public_host,
    public_protocol  => $ks_nova_public_proto,
  }

  class { 'neutron::keystone::auth':
    admin_address    => $ks_neutron_admin_host,
    internal_address => $ks_neutron_internal_host,
    password         => $ks_neutron_password,
    public_address   => $ks_neutron_public_host,
    public_protocol  => $ks_neutron_public_proto,
  }

  class { 'cinder::keystone::auth':
    admin_address    => $ks_cinder_admin_host,
    internal_address => $ks_cinder_internal_host,
    password         => $ks_cinder_password,
    public_address   => $ks_cinder_public_host,
    public_protocol  => $ks_cinder_public_proto,
  }

  class { 'glance::keystone::auth':
    admin_address    => $ks_glance_admin_host,
    internal_address => $ks_glance_internal_host,
    password         => $ks_glance_password,
    public_address   => $ks_glance_public_host,
    public_protocol  => $ks_glance_public_proto,
  }

  class { 'heat::keystone::auth':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    password         => $ks_heat_password,
    public_address   => $ks_heat_public_host,
    public_protocol  => $ks_heat_public_proto,
  }

  class { 'heat::keystone::auth_cfn':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    password         => $ks_heat_password,
    public_address   => $ks_heat_public_host,
    public_protocol  => $ks_heat_public_proto,
  }


  @@haproxy::balancermember{"${::fqdn}-keystone_api":
    listening_service => 'keystone_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $ks_keystone_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api_admin":
    listening_service => 'keystone_api_admin_cluster',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $ks_keystone_admin_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

# Todo(EmilienM): check if we still actually need this workaround. If not, we have to delete this section:
#
# Workaround for error "HTTPConnectionPool(host='127.0.0.1', port=35357): Max retries exceeded with url"
# In fact, when keystone finish to start but admin port isn't already usable, so wait a bit
# exec{'wait-keystone': command => '/bin/sleep 5' }
# Service['keystone'] -> Exec['wait-keystone']
# Exec['wait-keystone'] -> Keystone_tenant <| |>
# Exec['wait-keystone'] -> Keystone_user <| |>
# Exec['wait-keystone'] -> Keystone_role  <| |>
# Exec['wait-keystone'] -> Keystone_service <| |>
# Exec['wait-keystone'] -> Keystone_user_role <| |>
# Exec['wait-keystone'] -> Keystone_endpoint <| |>

}
