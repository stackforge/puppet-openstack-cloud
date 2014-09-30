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
# Unit tests for cloud::messaging class
#

require 'spec_helper'

describe 'cloud::messaging' do

  shared_examples_for 'openstack messaging' do

    let :params do
      {
        :rabbit_names      => ['foo','boo','zoo'],
        :rabbit_password   => 'secrete',
        :cluster_node_type => 'disc'
      }
    end

    it 'configure rabbitmq-server with default values' do
      is_expected.to contain_class('rabbitmq').with(
          :delete_guest_user        => true,
          :config_cluster           => true,
          :cluster_nodes            => params[:rabbit_names],
          :wipe_db_on_cookie_change => true,
          :cluster_node_type        => 'disc'
        )
    end

    context 'with RAM mode' do
      before :each do
        params.merge!( :cluster_node_type => 'ram')
      end

      it 'configure rabbitmq-server in RAM mode' do
       is_expected.to contain_class('rabbitmq').with( :cluster_node_type => 'ram' )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily      => 'Debian',
        :puppetversion => '3.3' }
    end

    it_configures 'openstack messaging'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily      => 'RedHat',
        :puppetversion => '3.3' }
    end

    it_configures 'openstack messaging'

    it 'should create rabbitmq binaries symbolic links' do
      is_expected.to contain_file('/usr/sbin/rabbitmq-plugins').with(
        :ensure => 'link',
        :target => '/usr/lib/rabbitmq/bin/rabbitmq-plugins'
      )
      is_expected.to contain_file('/usr/sbin/rabbitmq-env').with(
        :ensure => 'link',
        :target => '/usr/lib/rabbitmq/bin/rabbitmq-env'
      )
    end
  end

end
