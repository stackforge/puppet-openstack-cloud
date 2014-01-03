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
# Unit tests for os_dashboard
#

require 'spec_helper'

describe 'privatecloud::dashboard' do

  shared_examples_for 'openstack dashboard' do

    let :params do
      { :listen_ssl                 => false,
        :ks_keystone_internal_host  => 'localhost',
        :ks_keystone_internal_host  => 'localhost',
        :secret_key                 => '/etc/ssl/secret',
        :api_eth                    => '10.0.0.1' }
    end

    it 'configure horizon with some params' do
      should contain_class('horizon').with(
          :listen_ssl          => false,
          :secret_key          => '/etc/ssl/secret',
          :keystone_host       => 'localhost',
          :can_set_mount_point => 'False',
          :fqdn                => '10.0.0.1'
        )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '12.04',
        :concat_basedir         => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack dashboard'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack dashboard'
  end

end
