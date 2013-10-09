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

class os_role_keystone (
  $local_ip = $ipaddress_eth1,
){

  $encoded_user = uriescape($os_params::keystone_db_user)
  $encoded_password = uriescape($os_params::keystone_db_password)

# Running Keystone service with WSGI and Apache2
  class {'apache':
    default_vhost => false
  }

  class { 'keystone::wsgi::apache':
    port => 8082
  }

  apache::vhost { 'keystone_main_proxy':
    servername         => $::fqdn,
    port               => 5000,
    docroot            => $::keystone::params::keystone_wsgi_script_path,
    docroot_owner      => 'keystone',
    docroot_group      => 'keystone',
    error_log_file     => "${::fqdn}_main_error.log",
    access_log_file    => "${::fqdn}_main_access.log",
    configure_firewall => false,
    custom_fragment    => inline_template('
WSGIScriptAlias / /usr/lib/cgi-bin/keystone/main
WSGIProcessGroup keystone
')
  }

  apache::vhost { 'keystone_admin_proxy':
    servername         => $::fqdn,
    port               => 35357,
    docroot            => $::keystone::params::keystone_wsgi_script_path,
    docroot_owner      => 'keystone',
    docroot_group      => 'keystone',
    error_log_file     => "${::fqdn}_admin_error.log",
    access_log_file    => "${::fqdn}_admin_access.log",
    configure_firewall => false,
    custom_fragment    => inline_template('
WSGIScriptAlias / /usr/lib/cgi-bin/keystone/admin
WSGIProcessGroup keystone
')
  }

# Configure Keystone
  class { 'keystone':
    enabled        => false,
    package_ensure => 'latest',
    admin_token    => $os_params::ks_admin_token,
    compute_port   => "8774",
    verbose        => false,
    debug          => false,
    sql_connection => "mysql://${encoded_user}:${encoded_password}@${os_params::keystone_db_host}/keystone",
    idle_timeout   => 60,
# ToDo (EmilienM): Update to PKI tokens
    token_format   => "UUID",
  }

  keystone_config {
    "token/driver":     value => "keystone.token.backends.memcache.Token";
    "token/expiration": value => "86400";
    "memcache/servers": value => inline_template("<%= scope.lookupvar('os_params::keystone_memchached').join(',') %>");
    "ec2/driver":       value => "keystone.contrib.ec2.backends.sql.Ec2";
    "DEFAULT/syslog_log_facility": value => 'LOG_LOCAL0';
    "DEFAULT/use_syslog": value => 'yes';
  }

# Configure Load Balancers
  @@haproxy::balancermember{"${fqdn}-keystone":
    listening_service => "keystone_cluster",
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $os_params::keystone_port,
    options           => "check inter 2000 rise 2 fall 5"
  }

  @@haproxy::balancermember{"${fqdn}-keystone-admin":
    listening_service => "keystone_admin_cluster",
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => $os_params::keystone_admin_port,
    options           => "check inter 2000 rise 2 fall 5"
  }


# Keystone Endpoints + Users
  class { 'keystone::roles::admin': 
    email => $os_params::ks_admin_email,
    password => $os_params::ks_admin_password,
  }

  keystone_role { $os_params::keystone_roles_addons: ensure => present }

  class {"keystone::endpoint":
    public_address   => $os_params::ks_keystone_public_host,
    admin_address    => $os_params::ks_keystone_admin_host,
    internal_address => $os_params::ks_keystone_internal_host,
    public_port      => $os_params::ks_keystone_public_port,
    admin_port       => $os_params::keystone_admin_port,
    internal_port    => $os_params::keystone_port,
    region           => 'RegionOne',
    public_protocol  => $os_params::ks_keystone_public_proto
  }

  class{"swift::keystone::auth":
    password => $os_params::ks_swift_password,
    address => $os_params::ks_swift_internal_host,
    port => $os_params::swift_port,
    public_address => $os_params::ks_swift_public_host,
    public_protocol => $os_params::ks_swift_public_proto,
    public_port => $os_params::ks_swift_public_port
  }

  class { 'nova::keystone::auth':
    password         => $os_params::ks_nova_password,
    public_address   => $os_params::ks_nova_public_host,
    admin_address    => $os_params::ks_nova_admin_host,
    internal_address => $os_params::ks_nova_internal_host,
    public_protocol  => $os_params::ks_nova_public_proto,
    cinder => true,
  }

  class { 'cinder::keystone::auth':
    password         => $os_params::ks_cinder_password,
    public_address   => $os_params::ks_cinder_public_host,
    admin_address    => $os_params::ks_cinder_admin_host,
    internal_address => $os_params::ks_cinder_internal_host,
    public_protocol  => $os_params::ks_cinder_public_proto,
  }

  class { 'glance::keystone::auth':
    password         => $os_params::ks_glance_password,
    public_address   => $os_params::ks_glance_public_host,
    admin_address    => $os_params::ks_glance_admin_host,
    internal_address => $os_params::ks_glance_internal_host,
    public_protocol  => $os_params::ks_glance_public_proto,
  }

  class { 'quantum::keystone::auth':
    password         => $os_params::ks_quantum_password,
    public_address   => $os_params::ks_quantum_public_host,
    admin_address    => $os_params::ks_quantum_admin_host,
    internal_address => $os_params::ks_quantum_internal_host,
    public_protocol  => $os_params::ks_quantum_public_proto,
    port             => $os_params::quantum_port,
  }

  class { 'ceilometer::keystone::auth':
    password         => $os_params::ks_ceilometer_password,
    public_address   => $os_params::ks_ceilometer_public_host,
    admin_address    => $os_params::ks_ceilometer_admin_host,
    internal_address => $os_params::ks_ceilometer_internal_host,
    public_protocol  => $os_params::ks_ceilometer_public_proto,
    port             => $os_params::ceilometer_port,
  }

# Note for Midonet: endpoint is created manually since
# there is no Puppet module.

  keystone_tenant { $os_params::glance_swift_tenant:
    ensure      => present,
    enabled     => 'True',
    description => 'glance images tenant'
    } ->
  keystone_user { $os_params::glance_swift_user:
    ensure   => present,
    email    => "${os_params::glance_swift_user}@localhost",
    password => $os_params::glance_swift_password,
    tenant   => $os_params::glance_swift_tenant
  } -> 
  keystone_user_role { "${os_params::glance_swift_user}@${os_params::glance_swift_tenant}":
      ensure  => present,
      roles   => 'admin'
    }

  keystone_tenant { $os_params::ks_monitoring_tenant:
    ensure      => present,
    enabled     => 'True',
    description => 'Monitoring Tenant'
    } ->
  keystone_user { $os_params::ks_monitoring_user:
    ensure   => present,
    email    => "${os_params::ks_monitoring_user}@localhost",
    password => $os_params::ks_monitoring_password,
    tenant   => $os_params::ks_monitoring_tenant
  } -> 
  keystone_user_role { "${os_params::ks_monitoring_user}@${os_params::ks_monitoring_tenant}":
      ensure  => present,
      roles   => 'admin'
    }

# Specific to Midonet
#  keystone_tenant { $os_params::ks_midonet_tenant:
#    ensure      => present,
#    enabled     => 'True',
#    description => 'Midonet Tenant'
#    } ->
#  keystone_user { $os_params::ks_midonet_username:
#    ensure   => present,
#    email    => "${os_params::ks_midonet_tenant}@localhost",
#    password => $os_params::ks_midonet_password,
#    tenant   => $os_params::ks_midonet_tenant
#  } -> 
#  keystone_user_role { "${os_params::ks_midonet_user}@${os_params::ks_midonet_tenant}":
#      ensure  => present,
#      roles   => ${os_params::ks_midonet_role}
#    }

  class{ 'swift::keystone::dispersion':
    auth_pass => $os_params::ks_swift_dispersion_password
  }

# Waiting apache is configured before using keystone (because of WSGI)
  Service['httpd'] -> Keystone_tenant <| |>
  Service['httpd'] -> Keystone_user <| |>
  Service['httpd'] -> Keystone_role  <| |>
  Service['httpd'] -> Keystone_service <| |>
  Service['httpd'] -> Keystone_user_role <| |>
  Service['httpd'] -> Keystone_endpoint <| |>


# Due to Keystone WSGI, db need to be sync manually
  exec { 'keystone-manage db_sync':
    path        => '/usr/bin',
    user        => 'keystone',
    refreshonly => true,
    notify      => Service['keystone'],
    subscribe   => Package['keystone'],
    require     => User['keystone'],
  }

}
