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
# Unit tests for cloud::database:nosql::mongodb::mongod class
#

require 'spec_helper'

describe 'cloud::database::nosql::mongodb::mongod' do

  shared_examples_for 'openstack database nosql' do

    let :params do
      {
        :replset => { 'ceilometer' => { 'members' => ['10.0.0.1'] } }
      }
    end

    it 'configure mongodb::globals' do
      is_expected.to contain_class('mongodb::globals')
    end

    it 'configure mongodb::mongos' do
      is_expected.to contain_class('mongodb::server')
    end

    it 'configure mongodb replicasets' do
      is_expected.to contain_mongodb_replset('ceilometer').with(
        :members => ['10.0.0.1']
      )
    end

    context 'when enable is set to false' do
      before :each do
        params.merge!(:enable => false)
      end

      it 'does not configure mongodb::globals' do
        is_expected.not_to contain_class('mongodb::globals')
      end

      it 'does not configure mongodb::server' do
        is_expected.not_to contain_class('mongodb::server')
      end

    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure mongodb firewall rules' do
        is_expected.to contain_firewall('100 allow mongod access').with(
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
      it 'configure mongodb firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow mongod access').with(
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
      { :osfamily  => 'Debian',
        :lsbdistid => 'Debian' }
    end

    let :platform_params do
      { :manage_package_repo => true }
    end

    it_configures 'openstack database nosql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :manage_package_repo => false }
    end

    it_configures 'openstack database nosql'
  end

end

