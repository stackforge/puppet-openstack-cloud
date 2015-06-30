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
# Unit tests for cloud::network::contrail::rabbitmq
#

require 'spec_helper'

describe 'cloud::network::contrail::rabbitmq' do

  shared_examples_for 'contrail-rabbitmq settings' do

    let :params do
      { }
    end


    it 'configure the contrail rabbitmq-user' do
      is_expected.to contain_rabbitmq_user('contrail').with(
        :admin    => 'true',
        :password => 'contrailpassword',
        :provider => 'rabbitmqctl',
      )
    end

    it 'configure the contrail rabbitmq-user-permissions' do
      is_expected.to contain_rabbitmq_user_permissions('contrail@/').with(
        :configure_permission => '.*',
        :write_permission     => '.*',
        :read_permission      => '.*',
        :provider             => 'rabbitmqctl',
      )
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

    it_configures 'contrail-rabbitmq settings'
  end

end
