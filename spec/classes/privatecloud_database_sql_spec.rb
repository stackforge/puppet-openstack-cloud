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
        :neutron_db_user           => 'neutron',
        :neutron_db_password       => 'secrete',
        :neutron_db_allowed_hosts  => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :mysql_sys_maint           => 'sys' }
    end

    it 'configure mysql galera server' do
      should contain_class('mysql').with(
          :server_package_name => platform_params[:server_package_name],
          :client_package_name => platform_params[:client_package_name],
          :service_name => 'mysql'
        )

      should contain_class('mysql::server').with(
          :config_hash  => { 'bind_address' => '10.0.0.1', 'root_password' => 'secrete' },
          :notify       => 'Service[xinetd]'
        )
    end

    context 'configure databases on the galera master server' do

      before :each do
        facts.merge!( :hostname => '10.0.0.1' )
      end

      it 'configure keystone database' do
        should contain_class('keystone::db::mysql').with(
            :dbname        => 'keystone',
            :user          => 'keystone',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure glance database' do
        should contain_class('glance::db::mysql').with(
            :dbname        => 'glance',
            :user          => 'glance',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure nova database' do
        should contain_class('nova::db::mysql').with(
            :dbname        => 'nova',
            :user          => 'nova',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure cinder database' do
        should contain_class('cinder::db::mysql').with(
            :dbname        => 'cinder',
            :user          => 'cinder',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure neutron database' do
        should contain_class('neutron::db::mysql').with(
            :dbname        => 'neutron',
            :user          => 'neutron',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure heat database' do
        should contain_class('heat::db::mysql').with(
            :dbname        => 'heat',
            :user          => 'heat',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure monitoring database' do
        should contain_database('monitoring').with(
          :ensure   => 'present',
          :charset  => 'utf8'
        )
        should contain_database_user('clustercheckuser@localhost').with(
          :ensure        => 'present',
          :password_hash => '*FDC68394456829A7344C2E9D4CDFD43DCE2EFD8F',
          :provider      => 'mysql'
        )
        should contain_database_grant('clustercheckuser@localhost/monitoring').with(
          :privileges => 'all'
        )
        should contain_database_user('sys-maint@localhost').with(
          :ensure        => 'present',
          :password_hash => '*BE353D0D7826681F8B7C136ED9824915F5B99E7D',
          :provider      => 'mysql'
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :server_package_name => 'mariadb-galera-server',
        :client_package_name => 'mariadb-client',
        :wsrep_provider      => '/usr/lib/galera/libgalera_smm.so' }
    end

    it_configures 'openstack database sql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :server_package_name => 'MariaDB-Galera-server',
        :client_package_name => 'MariaDB-client',
        :wsrep_provider      => '/usr/lib64/galera/libgalera_smm.so' }
    end

    it_configures 'openstack database sql'
  end

end
