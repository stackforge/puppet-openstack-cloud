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
# == Class: privatecloud::identity
#
# Install Identity Server (Keystone)
#
# === Parameters:
#
# [*identity_roles_addons*]
#   (optional) Extra keystone roles to create
#   Default value in params
#
# [*keystone_db_host*]
#   (optional) Hostname or IP address to connect to keystone database
#   Default value in params
#
# [*keystone_db_user*]
#   (optional) Username to connect to keystone database
#   Default value in params
#
# [*keystone_db_password*]
#   (optional) Password to connect to keystone database
#   Default value in params
#
# [*memcache_servers*]
#   (optional) Memcached servers used by Keystone. Should be an array.
#   Default value in params
#
# [*ks_admin_email*]
#   (optional) Email address of admin user in Keystone
#   Default value in params
#
# [*ks_admin_password*]
#   (optional) Password of admin user in Keystone
#   Default value in params
#
# [*ks_admin_tenant*]
#   (optional) Admin tenant name in Keystone
#   Default value in params
#
# [*ks_admin_token*]
#   (optional) Admin token used by Keystone.
#   Default value in params
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Default value in params
#
# [*ks_glance_admin_host*]
#   (optional) Admin Hostname or IP to connect to Glance API
#   Default value in params
#
# [*ks_glance_public_host*]
#   (optional) Public Hostname or IP to connect to Glance API
#   Default value in params
#
# [*ks_ceilometer_internal_host*]
#   (optional) Internal Hostname or IP to connect to Ceilometer API
#   Default value in params
#
# [*ks_ceilometer_admin_host*]
#   (optional) Admin Hostname or IP to connect to Ceilometer API
#   Default value in params
#
# [*ks_ceilometer_public_host*]
#   (optional) Public Hostname or IP to connect to Ceilometer API
#   Default value in params
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_keystone_public_host*]
#   (optional) Public Hostname or IP to connect to Keystone API
#   Default value in params
#
# [*ks_nova_internal_host*]
#   (optional) Internal Hostname or IP to connect to Nova API
#   Default value in params
#
# [*ks_nova_admin_host*]
#   (optional) Admin Hostname or IP to connect to Nova API
#   Default value in params
#
# [*ks_nova_public_host*]
#   (optional) Public Hostname or IP to connect to Nova API
#   Default value in params
#
# [*ks_cinder_internal_host*]
#   (optional) Internal Hostname or IP to connect to Cinder API
#   Default value in params
#
# [*ks_cinder_admin_host*]
#   (optional) Admin Hostname or IP to connect to Cinder API
#   Default value in params
#
# [*ks_cinder_public_host*]
#   (optional) Public Hostname or IP to connect to Cinder API
#   Default value in params
#
# [*ks_neutron_internal_host*]
#   (optional) Internal Hostname or IP to connect to Neutron API
#   Default value in params
#
# [*ks_neutron_admin_host*]
#   (optional) Admin Hostname or IP to connect to Neutron API
#   Default value in params
#
# [*ks_neutron_public_host*]
#   (optional) Public Hostname or IP to connect to Neutron API
#   Default value in params
#
# [*ks_heat_internal_host*]
#   (optional) Internal Hostname or IP to connect to Heat API
#   Default value in params
#
# [*ks_heat_admin_host*]
#   (optional) Admin Hostname or IP to connect to Heat API
#   Default value in params
#
# [*ks_heat_public_host*]
#   (optional) Public Hostname or IP to connect to Heat API
#   Default value in params
#
# [*ks_swift_internal_host*]
#   (optional) Internal Hostname or IP to connect to Swift API
#   Default value in params
#
# [*ks_swift_admin_host*]
#   (optional) Admin Hostname or IP to connect to Swift API
#   Default value in params
#
# [*ks_swift_public_host*]
#   (optional) Public Hostname or IP to connect to Swift API
#   Default value in params
#
# [*ks_ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Default value in params
#
# [*ks_swift_password*]
#   (optional) Password used by Swift to connect to Keystone API
#   Default value in params
#
# [*ks_nova_password*]
#   (optional) Password used by Nova to connect to Keystone API
#   Default value in params
#
# [*ks_neutron_password*]
#   (optional) Password used by Neutron to connect to Keystone API
#   Default value in params
#
# [*ks_heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Default value in params
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Default value in params
#
# [*ks_cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Default value in params
#
# [*ks_swift_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_ceilometer_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_heat_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_nova_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_neutron_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_glance_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_cinder_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Default value in params
#
# [*ks_ceilometer_public_port*]
#   (optional) TCP port to connect to Ceilometer API from public network
#   Default value in params
#
# [*ks_ceilometer_internal_port*]
#   (optional) TCP port to connect to Ceilometer API from internal network
#   Default value in params
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from internal network
#   Default value in params
#
# [*ks_keystone_public_port*]
#   (optional) TCP port to connect to Keystone API from public network
#   Default value in params
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Default value in params
#
# [*ks_swift_internal_port*]
#   (optional) TCP port to connect to Swift API from internal network
#   Default value in params
#
# [*ks_swift_public_port*]
#   (optional) TCP port to connect to Swift API from public network
#   Default value in params
#
# [*api_eth*]
#   (optional) Which interface we bind the Keystone server.
#   Default value in params
#
# [*region*]
#   (optional) OpenStack Region Name
#   Default value in params
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Default value in params
#
# [*debug*]
#   (optional) Set log output to debug output
#   Default value in params
#

class privatecloud::identity (
  $identity_roles_addons        = $os_params::identity_roles_addons,
  $keystone_db_host             = $os_params::keystone_db_host,
  $keystone_db_user             = $os_params::keystone_db_user,
  $keystone_db_password         = $os_params::keystone_db_password,
  $memcache_servers             = $os_params::memcache_servers,
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
  $ks_nova_public_port          = $os_params::ks_nova_public_port,
  $ks_swift_dispersion_password = $os_params::ks_swift_dispersion_password,
  $ks_swift_internal_host       = $os_params::ks_swift_internal_host,
  $ks_swift_internal_port       = $os_params::ks_swift_internal_port,
  $ks_swift_password            = $os_params::ks_swift_password,
  $ks_swift_public_host         = $os_params::ks_swift_public_host,
  $ks_swift_public_port         = $os_params::ks_swift_public_port,
  $ks_swift_public_proto        = $os_params::ks_swift_public_proto,
  $api_eth                      = $os_params::api_eth,
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
    compute_port     => $ks_nova_public_port,
    debug            => $debug,
    idle_timeout     => 60,
    log_facility     => 'LOG_LOCAL0',
    memcache_servers => $memcache_servers,
    sql_connection   => "mysql://${encoded_user}:${encoded_password}@${keystone_db_host}/keystone",
    token_driver     => 'keystone.token.backends.memcache.Token',
    token_format     => 'UUID',
    use_syslog       => true,
    verbose          => $verbose,
    bind_host        => $api_eth,
    public_port      => $ks_keystone_public_port,
    admin_port       => $ks_keystone_admin_port
  }

  keystone_config {
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
    servername  => $::fqdn,
    admin_port  => $ks_keystone_admin_port,
    public_port => $ks_keystone_public_port,
    # TODO(EmilienM) not sure workers is useful when using WSGI backend
    workers     => $::processorcount,
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

  class {'swift::keystone::dispersion':
    auth_pass => $ks_swift_dispersion_password
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

  class { 'nova::keystone::auth':
    admin_address    => $ks_nova_admin_host,
    cinder           => true,
    internal_address => $ks_nova_internal_host,
    password         => $ks_nova_password,
    public_address   => $ks_nova_public_host,
    public_protocol  => $ks_nova_public_proto,
    region           => $region
  }

  class { 'neutron::keystone::auth':
    admin_address    => $ks_neutron_admin_host,
    internal_address => $ks_neutron_internal_host,
    password         => $ks_neutron_password,
    public_address   => $ks_neutron_public_host,
    public_protocol  => $ks_neutron_public_proto,
    region           => $region
  }

  class { 'cinder::keystone::auth':
    admin_address    => $ks_cinder_admin_host,
    internal_address => $ks_cinder_internal_host,
    password         => $ks_cinder_password,
    public_address   => $ks_cinder_public_host,
    public_protocol  => $ks_cinder_public_proto,
    region           => $region
  }

  class { 'glance::keystone::auth':
    admin_address    => $ks_glance_admin_host,
    internal_address => $ks_glance_internal_host,
    password         => $ks_glance_password,
    public_address   => $ks_glance_public_host,
    public_protocol  => $ks_glance_public_proto,
    region           => $region
  }

  class { 'heat::keystone::auth':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    password         => $ks_heat_password,
    public_address   => $ks_heat_public_host,
    public_protocol  => $ks_heat_public_proto,
    region           => $region
  }

  class { 'heat::keystone::auth_cfn':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    password         => $ks_heat_password,
    public_address   => $ks_heat_public_host,
    public_protocol  => $ks_heat_public_proto,
    region           => $region
  }


  @@haproxy::balancermember{"${::fqdn}-keystone_api":
    listening_service => 'keystone_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api_admin":
    listening_service => 'keystone_api_admin_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_admin_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
