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
# Unit tests for cloud::logging::agent class
#

require 'spec_helper'

describe 'cloud::logging::agent' do

  shared_examples_for 'openstack logging agent' do

    let :pre_condition do
      "class { 'cloud::logging': }
      include ::fluentd"
    end

    let :common_params do {
      :server => '127.0.0.1',
      :sources => {
        'apache' => {'type' => 'tail', 'configfile' => 'apache'},
        'syslog' => {'type' => 'tail', 'configfile' => 'syslog'}
      }
    }
    end


    context 'rsyslog is enabled' do
      let :params do 
        common_params.merge( {:syslog_enable => 'true' } )
      end

      it 'include cloud::loging' do
        it should contain_class('cloud::logging')
      end

      it 'include rsyslog::client' do
        it should contain_class('rsyglog::client')
      end

      it 'create /var/db/td-agent' do
        it should contain_file('/var/db/td-agent').with({
          :ensure => 'directory',
          :owner  => 'td-agent',
          :group  => 'td-agent',
        })
      end

    end

    context 'rsyslog is disabled' do
      let :params do 
        common_params.merge( {:syslog_enable => 'false' } )
      end

      it 'include cloud::loging' do
        it should contain_class('cloud::logging')
      end

      it 'include rsyslog::client' do
        it should_not contain_class('rsyglog::client')
      end

      it 'create /var/db/td-agent' do
        it should contain_file('/var/db/td-agent').with({
          :ensure => 'directory',
          :owner  => 'td-agent',
          :group  => 'td-agent',
        })
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack logging agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack logging agent'
  end

end
