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
# Unit tests for cloud::cache
#

require 'spec_helper'

describe 'cloud::cache' do

  shared_examples_for 'cache server' do

    let :params do
      { :listen_ip => '10.0.0.1' }
    end

    it 'configure memcached with some params' do
      should contain_class('memcached').with(
          :listen_ip           => '10.0.0.1',
          :max_memory          => '60%',
        )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :memorysize             => '1000 MB',
        :processorcount         => '1' }
    end

    it_configures 'cache server'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :memorysize             => '1000 MB',
        :processorcount         => '1' }
    end

    it_configures 'cache server'
  end

end
