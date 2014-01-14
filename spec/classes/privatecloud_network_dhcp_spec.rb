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
# Unit tests for cloud::network::dhcp class
#

require 'spec_helper'

describe 'cloud::network::dhcp' do

  shared_examples_for 'openstack network dhcp' do

    let :pre_condition do
      "class { 'cloud::network':
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        tunnel_eth              => '10.0.1.1',
        api_eth                 => '10.0.0.1',
        verbose                 => true,
        debug                   => true }"
    end

    let :params do
      { :debug => true }
    end

    it 'configure neutron common' do
      should contain_class('neutron').with(
          :allow_overlapping_ips   => true,
          :dhcp_agents_per_network => '2',
          :verbose                 => true,
          :debug                   => true,
          :rabbit_user             => 'neutron',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :bind_host               => '10.0.0.1',
          :core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
          :service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin']

      )
      should contain_class('neutron::agents::ovs').with(
          :enable_tunneling => true,
          :local_ip         => '10.0.1.1'
      )
      should contain_class('neutron::plugins::ml2').with(
          :type_drivers         => ['gre'],
          :tenant_network_types => ['gre'],
          :mechanism_drivers    => ['openvswitch'],
          :tunnel_id_ranges     => ['1:10000']
      )
      should contain_neutron_plugin_ml2('securitygroup/firewall_driver').with_value(true)
    end

    it 'configure neutron dhcp' do
      should contain_class('neutron::agents::dhcp').with(
          :debug => true
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack network dhcp'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack network dhcp'
  end

end
