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

  shared_examples_for 'openstack logging server' do

    let :pre_condition do
      "class { 'cloud::logging': }
      include ::fluentd"
    end

    let :params do {
      :server => '127.0.0.1',
      :sources => {
        'apache' => {'type' => 'tail', 'configfile' => 'apache'},
        'syslog' => {'type' => 'tail', 'configfile' => 'syslog'}
      }
    }
    end

    it 'configure logging common' do
      it should contain_concat("/etc/td-agent/config.d/forward.conf")
    end

    it 'config apache logging source' do
      it should contain_fluentd__configfile('apache')
      it should contain_fluentd__source('apache').with({
        :type       => 'tail',
        :configfile => 'apache',
      })
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack logging server'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack logging server'
  end

end
