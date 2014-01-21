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
# MySQL Galera Node
#

class cloud::database::sql (
    $api_eth                        = $os_params::api_eth,
    $service_provider               = 'sysv',
    $galera_nextserver              = $os_params::galera_nextserver,
    $galera_master                  = $os_params::galera_master,
    $keystone_db_host               = $os_params::keystone_db_host,
    $keystone_db_user               = $os_params::keystone_db_user,
    $keystone_db_password           = $os_params::keystone_db_password,
    $keystone_db_allowed_hosts      = $os_params::keystone_db_allowed_hosts,
    $cinder_db_host                 = $os_params::cinder_db_host,
    $cinder_db_user                 = $os_params::cinder_db_user,
    $cinder_db_password             = $os_params::cinder_db_password,
    $cinder_db_allowed_hosts        = $os_params::cinder_db_allowed_hosts,
    $glance_db_host                 = $os_params::glance_db_host,
    $glance_db_user                 = $os_params::glance_db_user,
    $glance_db_password             = $os_params::glance_db_password,
    $glance_db_allowed_hosts        = $os_params::glance_db_allowed_hosts,
    $heat_db_host                   = $os_params::heat_db_host,
    $heat_db_user                   = $os_params::heat_db_user,
    $heat_db_password               = $os_params::heat_db_password,
    $heat_db_allowed_hosts          = $os_params::heat_db_allowed_hosts,
    $nova_db_host                   = $os_params::nova_db_host,
    $nova_db_user                   = $os_params::nova_db_user,
    $nova_db_password               = $os_params::nova_db_password,
    $nova_db_allowed_hosts          = $os_params::nova_db_allowed_hosts,
    $neutron_db_host                = $os_params::neutron_db_host,
    $neutron_db_user                = $os_params::neutron_db_user,
    $neutron_db_password            = $os_params::neutron_db_password,
    $neutron_db_allowed_hosts       = $os_params::neutron_db_allowed_hosts,
    $mysql_root_password            = $os_params::mysql_root_password,
    $mysql_sys_maint_user           = $os_params::mysql_sys_maint_user,
    $mysql_sys_maint_password       = $os_params::mysql_sys_maint_password,
    $galera_clustercheck_dbuser     = $os_params::galera_clustercheck_dbuser,
    $galera_clustercheck_dbpassword = $os_params::galera_clustercheck_dbuser,
    $galera_clustercheck_ipaddress  = $::ipaddress
) {

  include 'xinetd'

  # TODO(Gonéri): OS/values detection should be moved in a params.pp
  case $::osfamily {
    'RedHat': {
        class { 'mysql':
            server_package_name => 'MariaDB-Galera-server',
            client_package_name => 'MariaDB-client',
            service_name        => 'mysql'
        }
        # galera-23.2.7-1.rhel6.x86_64
        $wsrep_provider = '/usr/lib64/galera/libgalera_smm.so'

        # TODO(Gonéri)
        # MariaDB-Galera-server-5.5.34-1.x86_64 doesn't create this
        $dirs = [ '/var/run/mysqld', '/var/log/mysql' ]
        file { $dirs:
            ensure => directory,
            mode   => '0750',
            before => Service['mysqld'],
            owner  => 'mysql'
        }

    }
    'Debian': {
        class { 'mysql':
            server_package_name => 'mariadb-galera-server',
            client_package_name => 'mariadb-client',
            service_name        => 'mysql'
        }
        $wsrep_provider = '/usr/lib/galera/libgalera_smm.so'
    }
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  class { 'mysql::server':
    config_hash         => {
      bind_address      => $api_eth,
      root_password     => $mysql_root_password,
    },
    notify              => Service['xinetd'],
  }

  if $::hostname == $galera_master {

# OpenStack DB
    class { 'keystone::db::mysql':
      dbname        => 'keystone',
      user          => $keystone_db_user,
      password      => $keystone_db_password,
      host          => $keystone_db_host,
      allowed_hosts => $keystone_db_allowed_hosts,
    }
    class { 'glance::db::mysql':
      dbname        => 'glance',
      user          => $glance_db_user,
      password      => $glance_db_password,
      host          => $glance_db_host,
      allowed_hosts => $glance_db_allowed_hosts,
    }
    class { 'nova::db::mysql':
      dbname        => 'nova',
      user          => $nova_db_user,
      password      => $nova_db_password,
      host          => $nova_db_host,
      allowed_hosts => $nova_db_allowed_hosts,
    }

    class { 'cinder::db::mysql':
      dbname        => 'cinder',
      user          => $cinder_db_user,
      password      => $cinder_db_password,
      host          => $cinder_db_host,
      allowed_hosts => $cinder_db_allowed_hosts,
    }

    class { 'neutron::db::mysql':
      dbname        => 'neutron',
      user          => $neutron_db_user,
      password      => $neutron_db_password,
      host          => $neutron_db_host,
      allowed_hosts => $neutron_db_allowed_hosts,
    }

    class { 'heat::db::mysql':
      dbname        => 'heat',
      user          => $heat_db_user,
      password      => $heat_db_password,
      host          => $heat_db_host,
      allowed_hosts => $heat_db_allowed_hosts,
    }


# Monitoring DB
    warning('Database mapping must be updated to puppetlabs/puppetlabs-mysql >= 2.x (see: https://dev.ring.enovance.com/redmine/issues/4510)')

    database { 'monitoring':
      ensure  => 'present',
      charset => 'utf8',
      require => File['/root/.my.cnf']
    }
    database_user { "${galera_clustercheck_dbuser}@localhost":
      ensure        => 'present',
      # can not change password in clustercheck script
      password_hash => mysql_password($galera_clustercheck_dbpassword),
      provider      => 'mysql',
      require       => File['/root/.my.cnf']
    }
    database_grant { "${galera_clustercheck_dbuser}@localhost/monitoring":
      privileges => ['all']
    }

    database_user { "${mysql_sys_maint_user}@localhost":
      ensure        => 'present',
      password_hash => mysql_password($mysql_sys_maint_password),
      provider      => 'mysql',
      require       => File['/root/.my.cnf']
    }

    Database_user<<| |>>

  } # if $::hostname == $galera_master

  # Haproxy http monitoring
  file_line { 'mysqlchk-in-etc-services':
    path   => '/etc/services',
    line   => 'mysqlchk 9200/tcp',
    match  => '^mysqlchk 9200/tcp$',
    notify => Service['xinetd'];
  }

  file {
    '/etc/xinetd.d/mysqlchk':
      content => template('cloud/database/mysqlchk.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/usr/bin/clustercheck'],
      notify  => Service['xinetd'];
    '/usr/bin/clustercheck':
      ensure  => present,
      content => template('cloud/database/clustercheck.erb'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root';
  }

  exec{'clean-mysql-binlog':
    # first sync take a long time
    command     => '/bin/bash -c "/usr/bin/mysqladmin --defaults-file=/root/.my.cnf shutdown ; killall -9 nc ; /bin/rm -f /var/lib/mysql/ib_logfile*  || { true ; sleep 60 ; }"',
    require     => [
      File['/root/.my.cnf'],
      Service['mysqld'],
    ],
    unless      => 'test `du -sh /var/lib/mysql/ib_logfile0 | cut -f1` = "256M"',
  }


  file{'/etc/mysql/sys.cnf':
    content => "# Managed by Puppet
# Module cloud::database::sql
[client]
host     = localhost
user     = sys-maint
password = ${mysql_sys_maint_password}
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = sys-maint
password = ${mysql_sys_maint_password}
socket   = /var/run/mysqld/mysqld.sock
basedir  = /usr
",
    mode    => '0600',
    require => Exec['clean-mysql-binlog'],
  }

  # TODO/WARNING(Gonéri): template changes do not trigger configuration changes
  mysql::server::config{'basic_config':
    notify_service => true,
    settings       => template('cloud/database/mysql.conf.erb'),
    require        => Exec['clean-mysql-binlog'];
  }

  @@haproxy::balancermember{$::fqdn:
    listening_service => 'galera_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @hostname != @galera_master -%>backup<% end %>')
  }

}
