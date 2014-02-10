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
# Unit tests for cloud::database:nosql class
#

require 'spec_helper'

describe 'cloud::database::nosql' do

  shared_examples_for 'openstack database nosql' do

    let :params do
      { :bind_ip   => '10.0.0.1',
        :nojournal => false }
    end

    it 'configure mongodb server' do
      should contain_class('mongodb::globals').with( :manage_package_repo => true)
      should contain_class('mongodb::globals').with_before('Class[Mongodb]')
      should contain_class('mongodb').with(
        :bind_ip   => ['10.0.0.1'],
        :nojournal => false
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack database nosql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack database nosql'
  end

end

