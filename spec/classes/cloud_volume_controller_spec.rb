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
# Unit tests for cloud::volume::controller class
#

require 'spec_helper'

describe 'cloud::volume::controller' do

  shared_examples_for 'openstack volume controller' do

    let :pre_condition do
      "class { 'cloud::volume':
        cinder_db_host             => '10.0.0.1',
        cinder_db_user             => 'cinder',
        cinder_db_password         => 'secrete',
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        ks_keystone_internal_host  => '10.0.0.1',
        ks_cinder_password         => 'secrete',
        verbose                    => true,
        debug                      => true }"
    end

    let :params do
      { :ks_cinder_password        => 'secrete',
        :ks_cinder_internal_port   => '8776',
        :ks_keystone_internal_host => '10.0.0.1',
        :ks_glance_internal_host   => '10.0.0.1',
        # TODO(EmilienM) Disabled for now: http://git.io/kfTmcA
        #:backup_ceph_user          => 'cinder',
        #:backup_ceph_pool          => 'ceph_backup_cinder',
        :api_eth                   => '10.0.0.1' }
    end

    it 'configure cinder common' do
      should contain_class('cinder').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'cinder',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true
        )
      should contain_class('cinder::ceilometer')
    end

    it 'checks if Cinder DB is populated' do
      should contain_exec('cinder_db_sync').with(
        :command => '/usr/bin/cinder-manage db sync',
        :unless  => '/usr/bin/mysql cinder -h 10.0.0.1 -u cinder -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure cinder scheduler' do
      should contain_class('cinder::scheduler')
    end

    # TODO(Emilien) Disabled for now: http://git.io/uM5sgg
    # it 'configure cinder glance backend' do
    #   should contain_class('cinder::glance').with(
    #       :glance_api_servers     => '10.0.0.1',
    #       :glance_request_timeout => '10'
    #     )
    # end
    # Replaced by:
    it 'configure cinder glance backend' do
      should contain_cinder_config('DEFAULT/glance_api_servers').with('value' => '10.0.0.1')
      should contain_cinder_config('DEFAULT/glance_request_timeout').with('value' => '10')
    end

    it 'configure cinder api' do
      should contain_class('cinder::api').with(
          :keystone_password  => 'secrete',
          :keystone_auth_host => '10.0.0.1',
          :bind_host          => '10.0.0.1'
        )
    end

    # TODO(EmilienM) Disabled for now: http://git.io/kfTmcA
    #it 'configure cinder backup using ceph backend' do
    #  should contain_class('cinder::backup')
    #  should contain_class('cinder::backup::ceph').with(
    #      :backup_ceph_user => 'cinder',
    #      :backup_ceph_pool => 'ceph_backup_cinder'
    #    )
    #end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack volume controller'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack volume controller'
  end

end
