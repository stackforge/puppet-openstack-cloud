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
# MySQL Galera Node
#

class os_sql_node (
    $local_ip                  = $ipaddress,
    $service_provider          = sysv,
    $galera_nextserver         = $os_params::galera_nextserver,
    $galera_master             = $os_params::galera_master,
    $mysql_password            = $os_params::mysql_password,
    $keystone_db_host          = $os_params::keystone_db_user,
    $keystone_db_user          = $os_params::keystone_db_host,
    $keystone_db_password      = $os_params::keystone_db_password,
    $keystone_db_allowed_hosts = $os_params::keystone_db_allowed_hosts,
    $cinder_db_host            = $os_params::cinder_db_user,
    $cinder_db_user            = $os_params::cinder_db_host,
    $cinder_db_password        = $os_params::cinder_db_password,
    $cinder_db_allowed_hosts   = $os_params::cinder_db_allowed_hosts,
    $glance_db_host            = $os_params::glance_db_user,
    $glance_db_user            = $os_params::glance_db_host,
    $glance_db_password        = $os_params::glance_db_password,
    $glance_db_allowed_hosts   = $os_params::glance_db_allowed_hosts,
    $heat_db_host              = $os_params::heat_db_user,
    $heat_db_user              = $os_params::heat_db_host,
    $heat_db_password          = $os_params::heat_db_password,
    $heat_db_allowed_hosts     = $os_params::heat_db_allowed_hosts,
    $nova_db_host              = $os_params::nova_db_user,
    $nova_db_user              = $os_params::nova_db_host,
    $nova_db_password          = $os_params::nova_db_password,
    $nova_db_allowed_hosts     = $os_params::nova_db_allowed_hosts,
    $neutron_db_host           = $os_params::neutron_db_user,
    $neutron_db_user           = $os_params::neutron_db_host,
    $neutron_db_password       = $os_params::neutron_db_password,
    $neutron_db_allowed_hosts  = $os_params::neutron_db_allowed_hosts,
    $mysql_debian_sys_maint    = $os_params::mysql_debian_sys_maint,
    $mysql_password            = $os_params::mysql_password
) {

  include 'xinetd'


  class { 'mysql::server':
    package_name      => 'mariadb-galera-server',
    config_hash       => {
      bind_address  => $local_ip,
      root_password => $mysql_password,
    },
    service_provider  => 'debian',
    require           => Apt::Source['mariadb'],
    notify            => Service['xinetd'],
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
    mysql_database { 'monitoring':
      ensure  => 'present',
      charset => 'utf8',
      require => File['/root/.my.cnf']
    }
    database_user { 'clustercheckuser@localhost':
      ensure        => 'present',
      # can not change password in clustercheck script
      password_hash => mysql_password('clustercheckpassword!'),
      provider      => 'mysql',
      require       => File['/root/.my.cnf']
    }
    database_grant { 'clustercheckuser@localhost/monitoring':
      privileges => ['all']
    }
    database_user { 'debian-sys-maint@localhost':
      ensure        => 'present',
      password_hash => mysql_password($mysql_debian_sys_maint),
      provider      => 'mysql',
      require       => File['/root/.my.cnf']
    }

    Database_user<<| |>>
  }

  # set the same debian_sys_maint password
  file{'/etc/mysql/debian.cnf':
    content => "# Automatically generated for Debian scripts. DO NOT TOUCH!
[client]
host     = localhost
user     = debian-sys-maint
password = ${mysql_debian_sys_maint}
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = debian-sys-maint
password = ${mysql_debian_sys_maint}
socket   = /var/run/mysqld/mysqld.sock
basedir  = /usr
",
    mode    => '0600',
  }

  # Disabled because monitor depends on checkmulti which is broken
  #  class { 'monitor::galera::httpsrv': }

  @@haproxy::balancermember{$::fqdn:
    listening_service => 'galera_cluster',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @hostname != @galera_master -%>backup<% end %>')
  }


  mysql::server::config{'basic_config':
    notify_service => false,
    notify         => Exec['clean-mysql-binlog'],
    settings       => inline_template('
[mysqld]
### dim : general ###
max_connections         = 1000
connect_timeout         = 5
wait_timeout            = 600
max_allowed_packet      = 64M
thread_cache_size       = 128
sort_buffer_size        = 4M
bulk_insert_buffer_size = 16M
tmp_table_size          = 128M
max_heap_table_size     = 128M
query_cache_limit  = 1M
query_cache_size   = 16M

### dim : myisam ###
myisam_recover          = BACKUP
key_buffer_size         = 16M
open-files-limit        = 65535
table_open_cache        = 500
table_definition_cache  = 500
myisam_sort_buffer_size = 512M
concurrent_insert       = 2
read_buffer_size        = 2M
read_rnd_buffer_size    = 1M

### dim : log ###
slow_query_log      = 1
slow_query_log_file = /var/log/mysql/slow.log
log_error           = /var/log/mysql/error.log
long_query_time     = 1
log_slow_verbosity  = query_plan

### dim : innodb conf  ###
innodb_buffer_pool_size         = 64M
innodb_flush_log_at_trx_commit  = 1
innodb_lock_wait_timeout        = 50
innodb_thread_concurrency       = 48
innodb_file_per_table           = 1
innodb_open_files               = 65535
innodb_io_capacity              = 1000
innodb_file_format              = Barracuda
innodb_file_format_max          = Barracuda
innodb_max_dirty_pages_pct      = 50

# sileht: mandatory for galera
binlog_format=ROW
innodb_autoinc_lock_mode=2
innodb_locks_unsafe_for_binlog=1
# sileht: galera stuff TODO: change login/password
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_name="os_galera_cluster"
<%- if hostname != galera_master -%>
wsrep_cluster_address="gcomm://<%= galera_nextserver[hostname] %>"
<%- else -%>
wsrep_cluster_address="gcomm://"
<%- end -%>
wsrep_sst_auth=root:<%= scope.lookupvar("$mysql_password") %>
wsrep_certify_nonPK=1
wsrep_convert_LOCK_to_trx=0
wsrep_auto_increment_control=1
wsrep_drupal_282555_workaround=0
wsrep_causal_reads=0
wsrep_sst_method=rsync
wsrep_node_address="<%= local_ip %>"
wsrep_node_incoming_address="<%= local_ip %>"

# this value here are used by /usr/bin/innobackupex
# and wsrep_sst_xtrabackup take only one configuration file and use the last one
# (/etc/mysql/my.cnf is not used)
datadir = /var/lib/mysql
tmpdir = /tmp
innodb_flush_method             = O_DIRECT
innodb_log_buffer_size          = 32M
innodb_log_file_size            = 256M
innodb_log_files_in_group       = 2
#innodb_data_file_path
#innodb_data_home_dir
#innodb_fast_checksum
#innodb_log_block_size
#innodb_log_group_home_dir
#innodb_page_size
'),
  }

  exec{'clean-mysql-binlog':
    # first sync take a long time
    command     => '/bin/bash -c "/usr/bin/mysqladmin --defaults-file=/root/.my.cnf shutdown ; killall -9 nc ; /bin/rm -f /var/lib/mysql/ib_logfile* ; /etc/init.d/mysql start || { true ; sleep 60 ; }"',
    require     => [
      File['/root/.my.cnf'],
      Service['mysqld'],
    ],
    refreshonly => true,
  }

}
