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
        debug                      => true,
        log_facility               => 'LOG_LOCAL0',
        use_syslog                 => true }"
    end

    let :params do
      { :volume_multi_backend       => true,
        :cinder_rbd_pool            => 'ceph_cinder',
        :cinder_rbd_user            => 'cinder',
        :cinder_rbd_secret_uuid     => 'secrete',
        :rbd_backend                => true,
        :rbd_backend_name           => 'lowcost',
        :ks_keystone_internal_proto => 'http',
        :ks_keystone_internal_port  => '5000',
        :ks_keystone_internal_host  => 'keystone.host',
        :ks_cinder_password         => 'secrete',
        :netapp_backend             => false }
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
          :use_syslog              => true,
          :log_dir                 => false
        )

      should contain_cinder_config('DEFAULT/notification_driver').with('value' => 'cinder.openstack.common.notifier.rpc_notifier')

    end

    it 'checks if Cinder DB is populated' do
      should contain_exec('cinder_db_sync').with(
        :command => '/usr/bin/cinder-manage db sync',
        :unless  => '/usr/bin/mysql cinder -h 10.0.0.1 -u cinder -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure cinder volume service' do
      should contain_class('cinder::volume')
    end

    context 'with RBD backend' do
      before :each do
        params.merge!( :rbd_backend => true )
      end

      it 'configures rbd volume driver' do
        should contain_cinder_config('lowcost/volume_backend_name').with_value('lowcost')
        should contain_cinder_config('lowcost/rbd_pool').with_value('ceph_cinder')
        should contain_cinder_config('lowcost/rbd_user').with_value('cinder')
        should contain_cinder_config('lowcost/rbd_secret_uuid').with_value('secrete')
        should contain_cinder__type('rbd').with(
          :set_key   => 'volume_backend_name',
          :set_value => 'lowcost'
        )
      end
    end

    context 'with NetApp backend' do
      before :each do
        params.merge!(
          :netapp_backend         => true,
          :netapp_backend_name    => 'premium',
          :netapp_server_hostname => 'netapp-server.host',
          :netapp_login           => 'joe',
          :netapp_password        => 'secrete'
        )
      end
      it 'configures netapp volume driver' do
        should contain_cinder_config('premium/volume_backend_name').with_value('premium')
        should contain_cinder_config('premium/netapp_login').with_value('joe')
        should contain_cinder_config('premium/netapp_password').with_value('secrete')
        should contain_cinder_config('premium/netapp_server_hostname').with_value('netapp-server.host')
        should contain_cinder__type('netapp').with(
          :set_key   => 'volume_backend_name',
          :set_value => 'premium'
        )
      end
    end

    context 'without any backend' do
      before :each do
        params.merge!(
          :netapp_backend => false,
          :rbd_backend    => false
        )
      end
      it 'should fail to configure cinder-volume'do
        expect { subject }.to raise_error(/no cinder backend has been enabled on storage nodes./)
      end
    end

    context 'with all backends enabled' do
      before :each do
        params.merge!(
          :netapp_backend => true,
          :rbd_backend    => true
        )
      end
      it 'configure all cinder backends' do
        should contain_class('cinder::backends').with(
          :enabled_backends => ['netapp', 'rbd']
        )
      end
    end

    context 'with backward compatiblity (without multi-backend)' do
      before :each do
        params.merge!(
          :volume_multi_backend => false,
        )
      end
      it 'configure rbd volume driver without multi-backend' do
        should contain_class('cinder::volume::rbd').with(
        :rbd_pool                         => 'ceph_cinder',
        :rbd_user                         => 'cinder',
        :rbd_secret_uuid                  => 'secrete',
        :rbd_ceph_conf                    => '/etc/ceph/ceph.conf',
        :rbd_flatten_volume_from_snapshot => false,
        :rbd_max_clone_depth              => '5',
        :glance_api_version               => '2'
        )
      end
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
