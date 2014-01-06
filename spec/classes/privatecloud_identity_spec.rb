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
# Unit tests for privatecloud::identity class
#

require 'spec_helper'

describe 'privatecloud::identity' do

  shared_examples_for 'openstack identity' do

    let :params do
      { :glance_db_host            => '10.0.0.1',
        :api_eth                   => '10.0.0.1' }
    end

    it 'configure keystone server' do
      should contain_class('keystone').with(
      )
    end

    it 'configure keystone admin role' do
      should contain_class('keystone::roles::admin').with(
      )
    end

    it 'configure apache to run keystone with wsgi' do
      should contain_class('keystone::wsgi::apache').with(
      )
    end

    it 'configure keystone endpoint' do
      should contain_class('keystone::endpoint').with(
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

#    it_configures 'openstack identity'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

#    it_configures 'openstack identity'
  end

end
