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
# Unit tests for cloud::logging::server class
#

require 'spec_helper'

describe 'cloud::logging::server' do

  shared_examples_for 'openstack logging server' do

    let :params do
      { :firewall_settings => {} }
    end

    it 'configure kibana' do
      is_expected.to contain_class('kibana3')
    end

    it 'configure the logging agent' do
      is_expected.to contain_class('cloud::logging::agent')
    end

    it 'configure elasticsearch' do
      is_expected.to contain_class('cloud::database::nosql::elasticsearch')
    end

    it 'configure an elasticsearch instance' do
      is_expected.to contain_elasticsearch__instance('fluentd')
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure kibana firewall rules' do
        is_expected.to contain_firewall('100 allow kibana access').with(
          :port   => '8300',
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
      it 'configure kibana firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow kibana access').with(
          :port   => '8300',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '7'
       }
    end

    it_configures 'openstack logging server'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7'
      }
    end

    it_configures 'openstack logging server'
  end

end
