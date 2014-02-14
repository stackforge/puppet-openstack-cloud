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
# Unit tests for cloud::compute::hypervisor class
#

require 'spec_helper'

describe 'cloud::compute::hypervisor' do

  shared_examples_for 'openstack compute hypervisor' do

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
        neutron_protocol        => 'http',
        neutron_endpoint        => '10.0.0.1',
        neutron_region_name     => 'MyRegion',
        neutron_password        => 'secrete',
        log_facility            => 'LOG_LOCAL0' }
       class { 'cloud::telemetry':
        ceilometer_secret          => 'secrete',
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        ks_keystone_internal_host  => '10.0.0.1',
        ks_keystone_internal_port  => '5000',
        ks_keystone_internal_proto => 'http',
        ks_ceilometer_password     => 'secrete',
        log_facility               => 'LOG_LOCAL0',
        use_syslog                 => true,
        verbose                    => true,
        debug                      => true }"
    end

    let :params do
      { :libvirt_type                         => 'kvm',
        :availability_zone                    => 'MyZone',
        :server_proxyclient_address           => '7.0.0.1',
        :spice_port                           => '6082',
        :has_ceph                             => true,
        :rbd_user                             => 'cinder',
        :rbd_pool                             => 'cinder',
        :rbd_secret_uuid                      => 'secrete',
        :nova_ssh_private_key                 => 'secrete',
        :nova_ssh_public_key                  => 'public',
        :ks_nova_public_proto                 => 'http',
        :ks_nova_public_host                  => '10.0.0.1' }
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

    it 'configure neutron on compute node' do
      should contain_class('nova::network::neutron').with(
          :neutron_admin_password => 'secrete',
          :neutron_admin_auth_url => 'http://10.0.0.1:35357/v2.0',
          :neutron_region_name    => 'MyRegion',
          :neutron_url            => 'http://10.0.0.1:9696'
      )
    end

    it 'configure ceilometer common' do
      should contain_class('ceilometer').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'ceilometer',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :metering_secret         => 'secrete',
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0'
        )
      should contain_class('ceilometer::agent::auth').with(
          :auth_password => 'secrete',
          :auth_url      => 'http://10.0.0.1:5000/v2.0'
      )
    end

    it 'configure neutron on compute node' do
      should contain_class('nova::network::neutron').with(
          :neutron_admin_password => 'secrete',
          :neutron_admin_auth_url => 'http://10.0.0.1:35357/v2.0',
          :neutron_region_name    => 'MyRegion',
          :neutron_url            => 'http://10.0.0.1:9696'
      )
    end

    it 'configure ceilometer common' do
      should contain_class('ceilometer').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'ceilometer',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :metering_secret         => 'secrete',
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0'
        )
      should contain_class('ceilometer::agent::auth').with(
          :auth_password => 'secrete',
          :auth_url      => 'http://10.0.0.1:5000/v2.0'
        )
    end

    it 'checks if Nova DB is populated' do
      should contain_exec('nova_db_sync').with(
        :command => '/usr/bin/nova-manage db sync',
        :unless  => '/usr/bin/mysql nova -h 10.0.0.1 -u nova -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'insert and activate nbd module' do
      should contain_exec('insert_module_nbd').with('command' => '/bin/echo "nbd" > /etc/modules', 'unless' => '/bin/grep "nbd" /etc/modules')
      should contain_exec('/sbin/modprobe nbd').with('unless' => '/bin/grep -q "^nbd " "/proc/modules"')
    end

    it 'configure nova-compute' do
      should contain_class('nova::compute').with(
          :enabled                       => true,
          :vnc_enabled                   => false,
          :virtio_nic                    => false,
          :neutron_enabled               => true
        )
    end

    it 'configure spice console' do
      should contain_class('nova::compute::spice').with(
          :server_listen              => '0.0.0.0',
          :server_proxyclient_address => '7.0.0.1',
          :proxy_host                 => '10.0.0.1',
          :proxy_protocol             => 'http',
          :proxy_port                 => '6082'
        )
    end

    it 'configure libvirt driver' do
      should contain_class('nova::compute::libvirt').with(
          :libvirt_type      => 'kvm',
          :vncserver_listen  => '0.0.0.0',
          :migration_support => true,
        )
    end

    it 'configure nova compute with neutron' do
      should contain_class('nova::compute::neutron')
    end

    it 'configure ceilometer agent compute' do
      should contain_class('ceilometer::agent::compute')
    end

    it 'configure nova-conpute to support RBD backend' do
      should contain_nova_config('DEFAULT/libvirt_images_type').with('value' => 'rbd')
      should contain_nova_config('DEFAULT/libvirt_images_rbd_pool').with('value' => 'cinder')
      should contain_nova_config('DEFAULT/libvirt_images_rbd_ceph_conf').with('value' => '/etc/ceph/ceph.conf')
      should contain_nova_config('DEFAULT/rbd_user').with('value' => 'cinder')
      should contain_nova_config('DEFAULT/rbd_secret_uuid').with('value' => 'secrete')
    end

    it 'configure nova-conpute with extra parameters' do
      should contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      should contain_nova_config('DEFAULT/libvirt_inject_key').with('value' => false)
      should contain_nova_config('DEFAULT/libvirt_inject_partition').with('value' => '-2')
      should contain_nova_config('DEFAULT/live_migration_flag').with('value' => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST')
    end

    context 'without RBD backend' do
      before :each do
        params.merge!( :has_ceph => false )
      end

      it 'should not configure nova-compute for RBD backend' do
        should_not contain_nova_config('DEFAULT/rbd_user').with('value' => 'nova')
      end
    end
 end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute hypervisor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack compute hypervisor'
  end

end
