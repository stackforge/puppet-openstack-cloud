#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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

require 'spec_helper'

describe 'cloud::database::nosql::mongos' do

  shared_examples_for 'mongodb mongos service' do

    let :params do
      { :replset_members   => ['10.0.0.1:27018', '10.0.0.2:27018'],
        :mongos_cfg_server => ['127.0.0.1:27019'],
        :sharding_keys     => [{'ceilometer.name' => {'name' => 1}}] }
    end

    context 'when enabled' do
      before :each do
        params.merge!(:enable => true)
      end
      it 'configure mongos service' do
        is_expected.to contain_class('mongodb::mongos').with({
          :configdb => ['127.0.0.1:27019'],
        })
      end
      it 'configure the ceilometer shard' do
        is_expected.to contain_mongodb_shard('ceilometer').with({
          :member => 'ceilometer/10.0.0.1:27018',
          :keys   => [{'ceilometer.name' => {'name' => 1}}],
        })
      end
    end

    context 'when disabled' do
      before :each do
        params.merge!(:enable => false)
      end
      it 'configure mongos service' do
        is_expected.not_to contain_class('mongodb::mongos')
      end
      it 'configure the ceilometer shard' do
        is_expected.not_to contain_mongodb_shard('ceilometer')
      end
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure mongodb firewall rules' do
        is_expected.to contain_firewall('100 allow mongos access').with(
          :port   => '27017',
          :proto  => 'tcp',
          :action => 'accept',
        )
      end
    end

    context 'with custom firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      before :each do
        params.merge!(:firewall_settings => { 'limit' => '50/sec' } )
      end
      it 'configure mongos firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow mongos access').with(
          :port   => '27017',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily  => 'Debian', }
    end

    it_configures 'mongodb mongos service'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'mongodb mongos service'
  end

end
