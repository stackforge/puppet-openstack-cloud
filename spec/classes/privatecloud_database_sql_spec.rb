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
# Unit tests for privatecloud::compute::hypervisor class
#

require 'spec_helper'

describe 'privatecloud::database::sql' do

  shared_examples_for 'openstack database sql' do

    let :pre_condition do
      "include xinetd"
    end

    let :params do
      { :service_provider          => 'sysv',
        :api_eth                   => '10.0.0.1',
        :galera_master             => '10.0.0.1',
        :galera_nextserver         => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :mysql_password            => 'secrete',
        :keystone_db_host          => '10.0.0.1',
        :keystone_db_user          => 'keystone',
        :keystone_db_password      => 'secrete',
        :keystone_db_allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :cinder_db_host            => '10.0.0.1',
        :cinder_db_user            => 'cinder',
        :cinder_db_password        => 'secrete',
        :cinder_db_allowed_hosts   => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :glance_db_host            => '10.0.0.1',
        :glance_db_user            => 'glance',
        :glance_db_password        => 'secrete',
        :glance_db_allowed_hosts   => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :heat_db_host              => '10.0.0.1',
        :heat_db_user              => 'heat',
        :heat_db_password          => 'secrete',
        :heat_db_allowed_hosts     => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :nova_db_host              => '10.0.0.1',
        :nova_db_user              => 'nova',
        :nova_db_password          => 'secrete',
        :nova_db_allowed_hosts     => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :neutron_db_host           => '10.0.0.1',
        :neutron_db_user           => 'glance',
        :neutron_db_password       => 'secrete',
        :neutron_db_allowed_hosts  => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :mysql_sys_maint           => 'sys' }
    end

    it 'configure mysql galera server' do
      should contain_class('mysql::server').with(
          :package_name => platform_params[:package_name],
          :service_name => 'mysql',
          :config_hash  => { 'bind_address' => '10.0.0.1', 'root_password' => 'secrete' },
          :notify       => 'Service[xinetd]'
        )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :package_name => 'mariadb-galera-server' }
    end

    it_configures 'openstack database sql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :package_name => 'MariaDB-Galera-server' }
    end

    it_configures 'openstack database sql'
  end

end
