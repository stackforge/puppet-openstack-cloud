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
# Unit tests for cloud::spof class
#

require 'spec_helper'

describe 'cloud::spof' do

  shared_examples_for 'cloud spof' do

    let :params do
      { :cluster_ip        => '10.0.0.1',
        :multicast_address => '239.1.1.2',
        :cluster_members   => false,
        :cluster_password  => 'verysecrete' }
    end

    context 'with Pacemaker on Debian' do
      before :each do
        facts.merge!( :osfamily => 'Debian' )
      end

      it 'configure pacemaker/corosync' do
        should contain_class('corosync').with(
          :enable_secauth    => false,
          :authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
          :bind_address      => '10.0.0.1',
          :multicast_address => '239.1.1.2',
        )
        should contain_file('/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central').with(
          :source => 'puppet:///modules/cloud/heartbeat/ceilometer-agent-central',
          :mode   => '0755',
          :owner  => 'root',
          :group  => 'root'
        )
        should contain_class('cloud::telemetry::centralagent').with(:enabled => false)
        should contain_exec('cleanup_ceilometer_agent_central').with(
          :command => 'crm resource cleanup ceilometer-agent-central',
          :path    => ['/usr/sbin', '/bin'],
          :user    => 'root',
          :unless  => 'crm resource show ceilometer-agent-central | grep Started'
        )
      end
    end

    context 'with Pacemaker on Red-Hat' do
      before :each do
        facts.merge!( :osfamily => 'RedHat' )
        params.merge!( :cluster_members => 'srv1 srv2 srv3')
      end

      it 'configure pacemaker/corosync' do
        should contain_class('pacemaker').with(:hacluster_pwd => 'verysecrete')
        should contain_class('pacemaker::stonith').with(:disable => true)
        should contain_class('pacemaker::corosync').with(
          :cluster_name     => 'openstack',
          :settle_timeout   => 10,
          :settle_tries     => 2,
          :settle_try_sleep => 5,
          :manage_fw        => false,
          :cluster_members  => 'srv1 srv2 srv3')
        should contain_file('/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central').with(
          :source => 'puppet:///modules/cloud/heartbeat/ceilometer-agent-central',
          :mode   => '0755',
          :owner  => 'root',
          :group  => 'root'
        )
        should contain_exec('pcmk_ceilometer_agent_central').with(
          :command => 'pcs resource create ceilometer-agent-central ocf:heartbeat:ceilometer-agent-central',
          :path    => ['/usr/bin','/usr/sbin','/sbin/','/bin'],
          :user    => 'root',
          :unless  => '/usr/sbin/pcs resource | /bin/grep ceilometer-agent-central | /bin/grep Started'
        )
        should contain_class('cloud::telemetry::centralagent').with(:enabled => false)
      end
    end

    context 'with Pacemaker on Red-Hat with missing parameters' do
      before :each do
        facts.merge!( :osfamily => 'RedHat' )
        params.merge!( :cluster_members => false)
      end
      it { should compile.and_raise_error(/cluster_members is a required parameter./) }
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat',
        :uniqueid       => '123' }
    end

    it_configures 'cloud spof'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat',
        :uniqueid       => '123' }
    end
    it_configures 'cloud spof'
  end

end
