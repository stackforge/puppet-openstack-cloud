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

describe 'privatecloud::compute::hypervisor' do

  shared_examples_for 'openstack compute hypervisor' do

    let :pre_condition do
      "class { 'privatecloud::compute':
        nova_db_host            => '10.0.0.1',
        nova_db_user            => 'nova',
        nova_db_password        => 'secrete',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        ks_glance_internal_host => '10.0.0.1',
        glance_port             => '9292',
        verbose                 => true,
        debug                   => true }"
    end

    let :params do
      { :libvirt_type                         => 'kvm',
        :api_eth                              => '10.0.0.1',
        :nova_ssh_private_key                 => 'secrete',
        :nova_ssh_public_key                  => 'public',
        :ks_nova_internal_proto               => 'http',
        :ks_nova_public_host                  => '7.7.7.7',
        :ks_nova_internal_host                => '10.0.0.1' }
    end

    it 'configure nova common' do
      should contain_class('nova').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'nova',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :database_connection     => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :glance_api_servers      => 'http://10.0.0.1:9292'
        )
      should contain_nova_config('DEFAULT/resume_guests_state_on_host_boot').with('value' => true)
    end

    it 'insert and activate nbd module' do
      should contain_exec('insert_module_nbd').with('command' => '/bin/echo "nbd" > /etc/modules', 'unless' => '/bin/grep "nbd" /etc/modules')
      should contain_exec('/sbin/modprobe nbd').with('unless' => '/bin/grep -q "^nbd " "/proc/modules"')
    end

    it 'start and stop isci service' do
      should contain_exec('/etc/init.d/open-iscsi start').with('onlyif' => '/bin/grep "GenerateName=yes" /etc/iscsi/initiatorname.iscsi')
      should contain_exec('/etc/init.d/open-iscsi stop').with('refreshonly' => true)
    end

    it 'configure nova-compute' do
      should contain_class('nova::compute').with(
          :enabled                       => true,
          :vncproxy_host                 => '7.7.7.7',
          :vncserver_proxyclient_address => '10.0.0.1',
          :virtio_nic                    => false,
          :neutron_enabled               => true
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
