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
# Unit tests for privatecloud::volume::controller class
#

require 'spec_helper'

describe 'privatecloud::volume::controller' do

  shared_examples_for 'openstack volume controller' do

    let :pre_condition do
      "class { 'privatecloud::volume':
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
        :ks_swift_internal_port    => '8080',
        :ks_swift_internal_host    => '10.0.0.1',
        :ks_swift_internal_proto   => 'http',
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

      should contain_cinder_config('DEFAULT/notification_driver').with('value' => 'cinder.openstack.common.notifier.rpc_notifier')

    end

    it 'configure cinder scheduler' do
      should contain_class('cinder::scheduler')
    end

    it 'configure cinder glance backend' do
      should contain_class('cinder::glance').with(
          :glance_api_servers     => '10.0.0.1',
          :glance_request_timeout => '10'
        )
    end

    it 'configure cinder api' do
      should contain_class('cinder::api').with(
          :keystone_password  => 'secrete',
          :keystone_auth_host => '10.0.0.1',
          :bind_host          => '10.0.0.1'
        )
    end

    it 'configure cinder backup using swift backend' do
      should contain_class('cinder::backup')
      should contain_class('cinder::backup::swift').with(
          :backup_swift_url => 'http://10.0.0.1:8080/v1/AUTH',
        )
    end

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
