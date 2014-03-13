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
# == Class: cloud::identity
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
# [*ks_ceilometer_admin_port*]
#   (optional) TCP port to connect to Ceilometer API from admin network
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
# [*ks_swift_public_port*]
#   (optional) TCP port to connect to Swift API from public network
#   Default value in params
#
# [*ks_nova_internal_port*]
#   (optional) TCP port to connect to Nova API from internal network
#   Default value in params
#
# [*ks_nova_public_port*]
#   (optional) TCP port to connect to Nova API from public network
#   Default value in params
#
# [*ks_ec2_public_port*]
#   (optional) TCP port to connect to EC2 API from public network
#   Default value in params
#
# [*ks_nova_admin_port*]
#   (optional) TCP port to connect to Nova API from admin network
#   Default value in params
#
# [*ks_cinder_internal_port*]
#   (optional) TCP port to connect to Cinder API from internal network
#   Default value in params
#
# [*ks_cinder_public_port*]
#   (optional) TCP port to connect to Cinder API from public network
#   Default value in params
#
# [*ks_cinder_admin_port*]
#   (optional) TCP port to connect to Cinder API from admin network
#   Default value in params
#
# [*ks_neutron_internal_port*]
#   (optional) TCP port to connect to Neutron API from internal network
#   Default value in params
#
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Default value in params
#
# [*ks_neutron_admin_port*]
#   (optional) TCP port to connect to Neutron API from admin network
#   Default value in params
#
# [*ks_heat_internal_port*]
#   (optional) TCP port to connect to Heat API from internal network
#   Default value in params
#
# [*ks_heat_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Default value in params
#
# [*ks_heat_admin_port*]
#   (optional) TCP port to connect to Heat API from admin network
#   Default value in params
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from internal network
#   Default value in params
#
# [*ks_glance_api_public_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Default value in params
#
# [*ks_glance_api_admin_port*]
#   (optional) TCP port to connect to Glance API from admin network
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
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults value in params
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults value in params
#
# [*token_expiration*]
#   (optional) Amount of time a token should remain valid (in seconds)
#   Defaults value in params
#
class cloud::identity (
  $swift_enabled                = $os_params::swift,
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
  $ks_cinder_public_port        = $os_params::ks_cinder_public_port,
  $ks_glance_admin_host         = $os_params::ks_glance_admin_host,
  $ks_glance_internal_host      = $os_params::ks_glance_internal_host,
  $ks_glance_password           = $os_params::ks_glance_password,
  $ks_glance_public_host        = $os_params::ks_glance_public_host,
  $ks_glance_public_proto       = $os_params::ks_glance_public_proto,
  $ks_glance_api_public_port    = $os_params::ks_glance_api_public_port,
  $ks_heat_admin_host           = $os_params::ks_heat_admin_host,
  $ks_heat_internal_host        = $os_params::ks_heat_internal_host,
  $ks_heat_password             = $os_params::ks_heat_password,
  $ks_heat_public_host          = $os_params::ks_heat_public_host,
  $ks_heat_public_proto         = $os_params::ks_heat_public_proto,
  $ks_heat_public_port          = $os_params::ks_heat_public_port,
  $ks_heat_cfn_public_port      = $os_params::ks_heat_cfn_public_port,
  $ks_ceilometer_public_port    = $os_params::ks_ceilometer_public_port,
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
  $ks_neutron_public_port       = $os_params::ks_neutron_public_port,
  $ks_nova_admin_host           = $os_params::ks_nova_admin_host,
  $ks_nova_internal_host        = $os_params::ks_nova_internal_host,
  $ks_nova_password             = $os_params::ks_nova_password,
  $ks_nova_public_host          = $os_params::ks_nova_public_host,
  $ks_nova_public_proto         = $os_params::ks_nova_public_proto,
  $ks_nova_public_port          = $os_params::ks_nova_public_port,
  $ks_ec2_public_port           = $os_params::ks_ec2_public_port,
  $ks_swift_dispersion_password = $os_params::ks_swift_dispersion_password,
  $ks_swift_internal_host       = $os_params::ks_swift_internal_host,
  $ks_swift_admin_host          = $os_params::ks_swift_admin_host,
  $ks_swift_password            = $os_params::ks_swift_password,
  $ks_swift_public_host         = $os_params::ks_swift_public_host,
  $ks_swift_public_port         = $os_params::ks_swift_public_port,
  $ks_swift_public_proto        = $os_params::ks_swift_public_proto,
  $api_eth                      = $os_params::api_eth,
  $region                       = $os_params::region,
  $verbose                      = $os_params::verbose,
  $debug                        = $os_params::debug,
  $log_facility                 = $os_params::log_facility,
  $use_syslog                   = $os_params::use_syslog,
  $ks_token_expiration          = $os_params::ks_token_expiration,
  $ks_token_driver              = 'keystone.token.backends.memcache.Token'
){

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
    keystone_config {
      'DEFAULT/log_file': ensure => absent;
    }
  } else {
    $log_dir = '/var/log/keystone'
  }

  $encoded_user     = uriescape($keystone_db_user)
  $encoded_password = uriescape($keystone_db_password)

# Configure Keystone
  class { 'keystone':
    enabled          => true,
    admin_token      => $ks_admin_token,
    compute_port     => $ks_nova_public_port,
    debug            => $debug,
    idle_timeout     => 60,
    log_facility     => $log_facility,
    memcache_servers => $memcache_servers,
    sql_connection   => "mysql://${encoded_user}:${encoded_password}@${keystone_db_host}/keystone",
    token_driver     => $ks_token_driver,
    token_provider   => 'keystone.token.providers.uuid.Provider',
    use_syslog       => $use_syslog,
    verbose          => $verbose,
    bind_host        => $api_eth,
    log_dir          => $log_dir,
    public_port      => $ks_keystone_public_port,
    admin_port       => $ks_keystone_admin_port,
    token_expiration => $ks_token_expiration
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

  # TODO(EmilienM) Disable WSGI - bug #98
  #include 'apache'
  # class {'keystone::wsgi::apache':
  #   servername  => $::fqdn,
  #   admin_port  => $ks_keystone_admin_port,
  #   public_port => $ks_keystone_public_port,
  #   # TODO(EmilienM) not sure workers is useful when using WSGI backend
  #   workers     => $::processorcount,
  #   ssl         => false
  # }

  if $swift_enabled {
    class {'swift::keystone::auth':
      address          => $ks_swift_internal_host,
      password         => $ks_swift_password,
      public_address   => $ks_swift_public_host,
      public_port      => $ks_swift_public_port,
      public_protocol  => $ks_swift_public_proto,
      admin_address    => $ks_swift_admin_host,
      internal_address => $ks_swift_internal_host,
      region           => $region
    }

    class {'swift::keystone::dispersion':
      auth_pass => $ks_swift_dispersion_password
    }
  }

  class {'ceilometer::keystone::auth':
    admin_address    => $ks_ceilometer_admin_host,
    internal_address => $ks_ceilometer_internal_host,
    public_address   => $ks_ceilometer_public_host,
    port             => $ks_ceilometer_public_port,
    region           => $region,
    password         => $ks_ceilometer_password
  }

  class { 'nova::keystone::auth':
    cinder           => true,
    admin_address    => $ks_nova_admin_host,
    internal_address => $ks_nova_internal_host,
    public_address   => $ks_nova_public_host,
    compute_port     => $ks_nova_public_port,
    ec2_port         => $ks_ec2_public_port,
    region           => $region,
    password         => $ks_nova_password
  }

  class { 'neutron::keystone::auth':
    admin_address    => $ks_neutron_admin_host,
    internal_address => $ks_neutron_internal_host,
    public_address   => $ks_neutron_public_host,
    port             => $ks_neutron_public_port,
    region           => $region,
    password         => $ks_neutron_password
  }

  class { 'cinder::keystone::auth':
    admin_address    => $ks_cinder_admin_host,
    internal_address => $ks_cinder_internal_host,
    public_address   => $ks_cinder_public_host,
    port             => $ks_cinder_public_port,
    region           => $region,
    password         => $ks_cinder_password
  }

  class { 'glance::keystone::auth':
    admin_address    => $ks_glance_admin_host,
    internal_address => $ks_glance_internal_host,
    public_address   => $ks_glance_public_host,
    port             => $ks_glance_api_public_port,
    region           => $region,
    password         => $ks_glance_password
  }

  class { 'heat::keystone::auth':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    public_address   => $ks_heat_public_host,
    port             => $ks_heat_public_port,
    region           => $region,
    password         => $ks_heat_password
  }

  class { 'heat::keystone::auth_cfn':
    admin_address    => $ks_heat_admin_host,
    internal_address => $ks_heat_internal_host,
    public_address   => $ks_heat_public_host,
    port             => $ks_heat_cfn_public_port,
    region           => $region,
    password         => $ks_heat_password
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Keystone DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Gonéri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-cloud/issues/156
  exec {'keystone_db_sync':
    command => '/usr/bin/keystone-manage db_sync',
    unless  => "/usr/bin/mysql keystone -h ${keystone_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
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
