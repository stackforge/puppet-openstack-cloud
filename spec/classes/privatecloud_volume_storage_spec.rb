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
# Unit tests for cloud::volume::storage class
#

require 'spec_helper'

describe 'cloud::volume::storage' do

  shared_examples_for 'openstack volume storage' do

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
      { :cinder_rbd_pool         => 'ceph_cinder',
        :cinder_rbd_user         => 'cinder',
        :cinder_rbd_secret_uuid  => 'secrete',
        :glance_api_version      => '2' }
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

    it 'configure cinder volume with rbd backend' do
      should contain_class('cinder::volume::rbd').with(
          :rbd_pool           => 'ceph_cinder',
          :glance_api_version => '2',
          :rbd_user           => 'cinder',
          :rbd_secret_uuid    => 'secrete'
        )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack volume storage'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack volume storage'
  end

end
