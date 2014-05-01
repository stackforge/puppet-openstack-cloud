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
# Unit tests for cloud
#

require 'spec_helper'

describe 'cloud' do

  let :params do
    { }
  end

  shared_examples_for 'private cloud node' do

    let :pre_condition do
      '
        include concat::setup
      '
    end

    let :file_defaults do
      {
        :mode    => '0644'
      }
    end
    it {should contain_file('/etc/motd').with(
      {:ensure => 'file'}.merge(file_defaults)
    )}

    it { should contain_service('cron').with({
      :name   => platform_params[:cron_service_name],
      :ensure => 'running',
      :enable => true
    }) }

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat',
        :puppetversion  => '3.3' }
    end

    let :platform_params do
      { :cron_service_name => 'cron'}
    end

    it_configures 'private cloud node'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat',
        :puppetversion  => '3.3',
        :hostname       => 'redhat1' }
    end

    let :platform_params do
      { :cron_service_name => 'crond'}
    end

    let :params do
      { :rhn_registration => { "username" => "rhn", "password" => "pass" } }
    end

    #it_configures 'private cloud node'

    xit { should contain_rhn_register('rhn-redhat1') }
  end

  context 'on other platforms' do
    let :facts do
      { :osfamily => 'Solaris' }
    end

    it { should compile.and_raise_error(/module puppet-openstack-cloud only support/) }

  end
end
