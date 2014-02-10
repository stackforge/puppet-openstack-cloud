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

    it 'should build motd file with correct message' do
        verify_contents(subject, '/etc/motd',
        [
          "############################################################################",
          "#                           eNovance IT Operations                         #",
          "############################################################################",
          "#                                                                          #",
          "#                         *** RESTRICTED ACCESS ***                        #",
          "#  Only the authorized users may access this system.                       #",
          "#  Any attempted unauthorized access or any action affecting the computer  #",
          "#  system of eNovance is punishable under articles 323-1 to 323-7 of       #",
          "#  French criminal law.                                                    #",
          "#                                                                          #",
          "############################################################################",
          "This node is under the control of Puppet ${::puppetversion}."
        ]
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat',
        :puppetversion  => '3.3' }
    end

#    it_configures 'private cloud node'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat',
        :puppetversion  => '3.3' }
    end

#    it_configures 'private cloud node'
  end

  context 'on other platforms' do
    let :facts do
      { :osfamily => 'Solaris' }
    end

    it 'should fail' do
      expect { subject }.to  raise_error(/module puppet-cloud only support/)
    end
  end



end
