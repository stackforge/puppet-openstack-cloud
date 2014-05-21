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
# Unit tests for cloud::image class
#
require 'spec_helper'

describe 'cloud::image::registry' do

  let :params do
    { :glance_db_host                   => '10.0.0.1',
      :glance_db_user                   => 'glance',
      :glance_db_password               => 'secrete',
      :ks_keystone_internal_host        => '10.0.0.1',
      :ks_glance_internal_host          => '10.0.0.1',
      :ks_glance_registry_internal_port => '9191',
      :ks_glance_password               => 'secrete',
      :debug                            => true,
      :verbose                          => true,
      :use_syslog                       => true,
      :log_facility                     => 'LOG_LOCAL0',
      :api_eth                          => '10.0.0.1'
    }
  end

  shared_examples_for 'openstack image registry' do

    it 'configure glance-registry' do
      should contain_class('glance::registry').with(
        :database_connection   => 'mysql://glance:secrete@10.0.0.1/glance?charset=utf8',
        :keystone_password     => 'secrete',
        :keystone_tenant       => 'services',
        :keystone_user         => 'glance',
        :verbose               => true,
        :debug                 => true,
        :auth_host             => '10.0.0.1',
        :log_facility          => 'LOG_LOCAL0',
        :bind_host             => '10.0.0.1',
        :bind_port             => '9191',
        :use_syslog            => true,
        :log_dir               => false,
        :log_file              => false
      )
    end

    it 'checks if Glance DB is populated' do
      should contain_exec('glance_db_sync').with(
        :command => 'glance-manage db_sync',
        :user    => 'glance',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql glance -h 10.0.0.1 -u glance -psecrete -e "show tables" | /bin/grep Tables'
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack image registry'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack image registry'
  end

end
