#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::debian::galera_patch
#
# Install a dedicated mysqld init script
#
# This is due to this bug: https://bugs.launchpad.net/codership-mysql/+bug/1087368
#
# The backport to API 23 requires a command line option --wsrep-new-cluster:
#
# http://bazaar.launchpad.net/~codership/codership-mysql/wsrep-5.5/revision/3844?start_revid=3844
#
# and the mysql init script cannot have arguments passed to the daemon
# using /etc/default/mysql standart mechanism
#
# To check that the mysqld support the options you can :
# strings `which mysqld` | grep wsrep-new-cluster
#
# TODO: to be remove as soon as the API 25 is packaged, ie galera 3 ...
class cloud::debian::galera_patch (
  ) {

  # replace the file
  file { '/etc/init.d/mysql-bootstrap':
    content => template('cloud/database/etc_initd_mysql'),
    owner   => 'root',
    mode    => '0755',
    group   => 'root',
    notify  => Service['mysqld'],
    before  => Package['mysql-server'],
  }
}
