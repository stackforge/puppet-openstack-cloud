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
        availability_zone       => 'MyZone',
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
        memcache_servers        => ['10.0.0.1','10.0.0.2'],
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
        debug                      => true }
       class { 'cloud::network':
        rabbit_hosts             => ['10.0.0.1'],
        rabbit_password          => 'secrete',
        tunnel_eth               => '10.0.1.1',
        api_eth                  => '10.0.0.1',
        provider_vlan_ranges     => ['physnet1:1000:2999'],
        provider_bridge_mappings => ['physnet1:br-eth1'],
        verbose                  => true,
        debug                    => true,
        use_syslog               => true,
        log_facility             => 'LOG_LOCAL0' }"
    end

    let :params do
      { :libvirt_type                         => 'kvm',
        :server_proxyclient_address           => '7.0.0.1',
        :spice_port                           => '6082',
        :has_ceph                             => true,
        :cinder_rbd_user                      => 'cinder',
        :nova_rbd_pool                        => 'nova',
        :nova_rbd_secret_uuid                 => 'secrete',
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
          :memcached_servers       => ['10.0.0.1','10.0.0.2'],
          :database_connection     => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :glance_api_servers      => 'http://10.0.0.1:9292',
          :log_dir                 => false
        )
      should contain_nova_config('DEFAULT/resume_guests_state_on_host_boot').with('value' => true)
      should contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      should contain_nova_config('DEFAULT/servicegroup_driver').with_value('mc')
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

    it 'configure neutron common' do
      should contain_class('neutron').with(
          :allow_overlapping_ips   => true,
          :dhcp_agents_per_network => '2',
          :verbose                 => true,
          :debug                   => true,
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true,
          :rabbit_user             => 'neutron',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :bind_host               => '10.0.0.1',
          :core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
          :service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
          :log_dir                 => false
      )
      should contain_class('neutron::agents::ovs').with(
          :enable_tunneling => true,
          :tunnel_types     => ['gre'],
          :bridge_mappings  => ['physnet1:br-eth1'],
          :local_ip         => '10.0.1.1'
      )
      should contain_class('neutron::plugins::ml2').with(
          :type_drivers           => ['gre','vlan'],
          :tenant_network_types   => ['gre'],
          :mechanism_drivers      => ['openvswitch','l2population'],
          :tunnel_id_ranges       => ['1:10000'],
          :network_vlan_ranges    => ['physnet1:1000:2999'],
          :enable_security_group  => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
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
        :command => 'nova-manage db sync',
        :path    => '/usr/bin',
        :user    => 'nova',
        :unless  => '/usr/bin/mysql nova -h 10.0.0.1 -u nova -psecrete -e "show tables" | /bin/grep Tables'
      )
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
          :libvirt_disk_cachemodes => ['network=writeback']
        )
    end

    it 'configure nova compute with neutron' do
      should contain_class('nova::compute::neutron')
    end

    it 'configure ceilometer agent compute' do
      should contain_class('ceilometer::agent::compute')
    end

    it 'configure nova-compute to support RBD backend' do
      should contain_nova_config('DEFAULT/libvirt_images_type').with('value' => 'rbd')
      should contain_nova_config('DEFAULT/libvirt_images_rbd_pool').with('value' => 'nova')
      should contain_nova_config('DEFAULT/libvirt_images_rbd_ceph_conf').with('value' => '/etc/ceph/ceph.conf')
      should contain_nova_config('DEFAULT/rbd_user').with('value' => 'cinder')
      should contain_nova_config('DEFAULT/rbd_secret_uuid').with('value' => 'secrete')
      should contain_group('cephkeyring').with(:ensure => 'present')
      should contain_exec('add-nova-to-group').with(
        :command => 'usermod -a -G cephkeyring nova',
        :unless  => 'groups nova | grep cephkeyring',
        :path    => ['/usr/sbin', '/sbin']
      )
    end

    it 'configure nova-compute with extra parameters' do
      should contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      should contain_nova_config('DEFAULT/libvirt_inject_key').with('value' => false)
      should contain_nova_config('DEFAULT/libvirt_inject_partition').with('value' => '-2')
      should contain_nova_config('DEFAULT/live_migration_flag').with('value' => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST')
    end

    context 'with dbus on Ubuntu' do
      let :facts do
        { :osfamily        => 'Debian',
          :operatingsystem => 'Ubuntu',
          :concat_basedir  => '/var/lib/puppet/concat'
        }
      end

      it 'ensure dbus is running and started at boot' do
        should contain_service('dbus').with(
          :ensure => 'running',
          :enable => 'true'
        )
      end
    end

    context 'without RBD backend' do
      before :each do
        params.merge!( :has_ceph => false )
      end

      it 'should not configure nova-compute for RBD backend' do
        should_not contain_nova_config('DEFAULT/rbd_user').with('value' => 'cinder')
      end
      it 'configure libvirt driver without disk cachemodes' do
        should contain_class('nova::compute::libvirt').with(
            :libvirt_type      => 'kvm',
            :vncserver_listen  => '0.0.0.0',
            :migration_support => true,
            :libvirt_disk_cachemodes => []
          )
      end
    end
 end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :concat_basedir  => '/var/lib/puppet/concat'
      }
    end

    let :platform_params do
      { :gre_module_name => 'gre' }
    end

    it_configures 'openstack compute hypervisor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    let :platform_params do
      { :gre_module_name => 'ip_gre' }
    end

    it_configures 'openstack compute hypervisor'
  end

end
