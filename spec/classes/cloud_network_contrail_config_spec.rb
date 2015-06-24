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
# Unit tests for cloud::network::contrail::config
#

require 'spec_helper'

describe 'cloud::network::contrail::config' do

  shared_examples_for 'contrail-config server' do

    let :params do
      { }
    end

    it 'configure contrail-config' do
      is_expected.to contain_class('contrail::config')
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure contrail-config firewall rules' do
        is_expected.to contain_firewall('100 allow contrail config access').with(
          :port   => ['8443', '8087', '8088', '9110', '9100'],
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
      it 'configure contrail-config firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow contrail config access').with(
          :port   => ['8443', '8087', '8088', '9110', '9100'],
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'contrail-config server'
  end

end
