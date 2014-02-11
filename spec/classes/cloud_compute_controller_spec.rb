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
# Unit tests for cloud::compute::controller class
#

require 'spec_helper'

describe 'cloud::compute::controller' do

  shared_examples_for 'openstack compute controller' do

    let :pre_condition do
      "class { 'cloud::compute':
        nova_db_host            => '10.0.0.1',
        nova_db_user            => 'nova',
        nova_db_password        => 'secrete',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        ks_glance_internal_host => '10.0.0.1',
        glance_api_port         => '9292',
        verbose                 => true,
        debug                   => true,
        use_syslog              => true,
        log_facility            => 'LOG_LOCAL0' }"
    end

    let :params do
      { :ks_keystone_internal_host            => '10.0.0.1',
        :ks_nova_password                     => 'secrete',
        :api_eth                              => '10.0.0.1',
        :spice_port                           => '6082',
        :ks_ec2_public_port                   => '8773',
        :ks_nova_public_port                  => '8774',
        :ks_metadata_public_port              => '8775',
        :neutron_metadata_proxy_shared_secret => 'secrete' }
    end

    it 'configure nova common' do
      should contain_class('nova').with(
          :verbose                 => true,
          :debug                   => true,
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0',
          :rabbit_userid           => 'nova',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :database_connection     => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :glance_api_servers      => 'http://10.0.0.1:9292'
        )
      should contain_nova_config('DEFAULT/resume_guests_state_on_host_boot').with('value' => true)
    end

    it 'checks if Nova DB is populated' do
      should contain_exec('nova_db_sync').with(
        :command => '/usr/bin/nova-manage db sync',
        :unless  => '/usr/bin/mysql nova -h 10.0.0.1 -u nova -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure nova-scheduler' do
      should contain_class('nova::scheduler').with(:enabled => true)
    end

    it 'configure nova-spicehtml5proxy' do
      should contain_class('nova::spicehtml5proxy').with(:enabled => true)
    end

    it 'configure nova-cert' do
      should contain_class('nova::cert').with(:enabled => true)
    end

    it 'configure nova-consoleauth' do
      should contain_class('nova::consoleauth').with(:enabled => true)
    end

    it 'configure nova-conductor' do
      should contain_class('nova::conductor').with(:enabled => true)
    end

    it 'configure nova-api' do
      should contain_class('nova::api').with(
          :enabled                              => true,
          :auth_host                            => '10.0.0.1',
          :admin_password                       => 'secrete',
          :api_bind_address                     => '10.0.0.1',
          :neutron_metadata_proxy_shared_secret => 'secrete'
        )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute controller'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack compute controller'
  end

end
