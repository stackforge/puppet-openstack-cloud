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
        :cluster_node_type => 'disc',
        :rabbit_names      => ['foo','boo','zoo'],
        :rabbit_password   => 'secrete',
        :erlang_cookie     => 'MY_COOKIE',
        :rabbitmq_ip       => '10.0.0.1',
        :haproxy_binding   => false,
      }
    end

    it 'configure rabbitmq-server with default values' do
      is_expected.to contain_class('rabbitmq').with(
          :delete_guest_user        => true,
          :config_cluster           => true,
          :cluster_nodes            => params[:rabbit_names],
          :wipe_db_on_cookie_change => true,
          :cluster_node_type        => params[:cluster_node_type],
          :node_ip_address          => params[:rabbitmq_ip],
          :erlang_cookie            => params[:erlang_cookie],
          :port                     => '5672',
          :package_provider         => platform_params[:package_provider],
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

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure rabbitmq firewall rules' do
        is_expected.to contain_firewall('100 allow rabbitmq access').with(
          :port   => '5672',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow rabbitmq management access').with(
          :port   => '55672',
          :proto  => 'tcp',
          :action => 'accept',
        )
      end
    end

    context 'with custom firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      before :each do
        params.merge!(:firewall_settings => { 'limit' => '50/sec' } )
      end
      it 'configure rabbitmq firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow rabbitmq management access').with(
          :port   => '55672',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

    context 'with HAproxy binding and HA policy to exactly' do
      before :each do
        params.merge!(
          :haproxy_binding => true,
          :cluster_count   => 3,
        )
      end

      it 'configure ha-exactly rabbitmq_policy' do
       is_expected.to contain_rabbitmq_policy('ha-exactly-3@/').with(
         :pattern    => '^(?!amq\.).*',
         :definition => {
           'ha-mode'   => 'exactly',
           'ha-params' => 3,
         },
       )
      end
    end

    context 'with HAproxy binding and HA policy to all' do
      before :each do
        params.merge!(
          :haproxy_binding => true,
        )
      end

      it 'configure ha-exactly rabbitmq_policy' do
       is_expected.to contain_rabbitmq_policy('ha-all@/').with(
         :pattern    => '^(?!amq\.).*',
         :definition => {
           'ha-mode'   => 'all',
         },
       )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :package_provider => 'apt' }
    end

    it_configures 'openstack messaging'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end


    let :platform_params do
      { :package_provider => 'yum' }
    end

    let :params do
      { :erlang_cookie => 'MY_COOKIE' }
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
