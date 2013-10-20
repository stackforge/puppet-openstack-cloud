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

class os_keystone_server (
  $local_ip = $ipaddress_eth1,
){

# python-memcache is not a dependency (yet)
  package { 'python-memcache':
    ensure => lastest
  }

# Create the DB
  class { 'keystone::db::mysql':
    password      => $os_params::keystone_db_password,
    user          => $os_params::keystone_db_user,
    dbname        => 'keystone',
    host          => $os_params::keystone_db_host,
    allowed_hosts => $os_params::keystone_allowed_hosts,
  }

# Configure Keystone
  class { 'keystone':
    enabled        => true,
    package_ensure => 'latest',
    admin_token    => $os_params::ks_admin_token,
    compute_port   => "8774",
    verbose        => true,
    debug          => true,
    sql_connection => "mysql://${os_params::keystone_db_user}:${os_params::keystone_db_password}@${os_params::keystone_db_host}/keystone",
    idle_timeout   => 60,
    token_format   => "UUID",
    token_driver   => "keystone.token.backends.memcache.Token",
    use_syslog     => true,
    log_facility   => "LOG_LOCAL0",
  }

  keystone_config {
    "token/expiration": value => "86400";
    "memcache/servers": value => inline_template("<%= scope.lookupvar('os_params::keystone_memchached').join(',') %>");
    "ec2/driver":       value => "keystone.contrib.ec2.backends.sql.Ec2";
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
    region           => $os_params::region,
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

  class { 'ceilometer::keystone::auth':
    password         => $os_params::ks_ceilometer_password,
    public_address   => $os_params::ks_ceilometer_public_host,
    admin_address    => $os_params::ks_ceilometer_admin_host,
    internal_address => $os_params::ks_ceilometer_internal_host,
    public_protocol  => $os_params::ks_ceilometer_public_proto,
    port             => $os_params::ceilometer_port,
  }

  class{ 'swift::keystone::dispersion':
    auth_pass => $os_params::ks_swift_dispersion_password
  }

}
