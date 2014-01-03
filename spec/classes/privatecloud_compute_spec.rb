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
# Unit tests for privatecloud::compute class
#

require 'spec_helper'

describe 'privatecloud::compute' do

  shared_examples_for 'openstack compute class' do

    let :params do
      { :nova_db_host               => '10.0.0.1',
        :nova_db_user               => 'nova',
        :nova_db_password           => 'secrete',
        :rabbit_hosts               => ['10.0.0.1'],
        :rabbit_password            => 'secrete',
        :ks_glance_internal_host    => '10.0.0.1',
        :glance_port                => '9292',
        :verbose                    => true,
        :debug                      => true }
    end

    it 'configure compute class' do
      should contain_class('nova').with(
          :database_connection => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :rabbit_userid       => 'nova',
          :rabbit_hosts        => '10.0.0.1',
          :rabbit_password     => 'secrete',
          :glance_api_servers  => 'http://10.0.0.1:9292',
          :verbose             => true,
          :debug               => true
        )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute class'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack compute class'
  end

end
