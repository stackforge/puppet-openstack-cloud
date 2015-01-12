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
# Unit tests for cloud::selinux
#

require 'spec_helper'

describe 'cloud::selinux' do

  shared_examples_for 'manage selinux' do

    context 'with selinux disabled' do
      before :each do
        facts.merge!( :selinux_current_mode => 'enforcing' )
      end

      let :params do
        { :mode       => 'disabled',
          :booleans   => ['foo', 'bar'],
          :modules    => ['module1', 'module2'],
          :directory  => '/path/to/modules'}
      end

      it 'runs setenforce 0' do
        is_expected.to contain_exec('setenforce 0')
      end

      it 'enables the SELinux boolean' do
        is_expected.to contain_selboolean('foo').with(
          :persistent => true,
          :value      => 'on',
        )
      end

      it 'enables the SELinux modules' do
        is_expected.to contain_selmodule('module1').with(
          :ensure       => 'present',
          :selmoduledir => '/path/to/modules',
        )
      end

    end

    context 'with selinux enforcing' do
      before :each do
        facts.merge!( :selinux => 'false' )
      end

      let :params do
        { :mode       => 'enforcing',
          :booleans   => ['foo', 'bar'],
          :modules    => ['module1', 'module2'],
          :directory  => '/path/to/modules'}
      end

      it 'runs setenforce 1' do
        is_expected.to contain_exec('setenforce 1')
      end

      it 'enables the SELinux boolean' do
        is_expected.to contain_selboolean('foo').with(
          :persistent => true,
          :value      => 'on',
        )
      end

      it 'enables the SELinux modules' do
        is_expected.to contain_selmodule('module1').with(
          :ensure       => 'present',
          :selmoduledir => '/path/to/modules',
        )
      end

    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian' }
    end

    it_raises 'a Puppet::Error', /OS family unsuppored yet \(Debian\), SELinux support is only limited to RedHat family OS/
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'manage selinux'
  end

end
