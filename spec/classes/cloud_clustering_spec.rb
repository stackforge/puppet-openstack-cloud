#
# Copyright (C) 2015 Red Hat Inc.
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
# Unit tests for cloud::clustering class
#

require 'spec_helper'

describe 'cloud::clustering' do

  let :pre_condition do
    "class { 'cloud':
      manage_firewall => true
    }"
  end

  let :params do
    { :cluster_members          => ['node1.test-example.org',
                                    'node2.test-example.org',
                                    'node3.test-example.org'],
      :cluster_ip               => '127.0.0.1',
      :cluster_auth             => false,
      :cluster_authkey          => '/var/lib/puppet/ssl/certs/ca.pem',
      :cluster_recheck_interval => '5min',
      :pe_warn_series_max       => 1000,
      :pe_input_series_max      => 1000,
      :pe_error_series_max      => 1000,
      :multicast_address        => '239.192.168.1',
      :firewall_settings        => {} }
  end

  shared_examples_for 'corosync and pacemaker' do

    context 'with default parameters' do
      it 'configure corosync' do
        is_expected.to contain_class('corosync').with(
          :enable_secauth    => params[:cluster_auth],
          :authkey           => params[:cluster_authkey],
          :bind_address      => params[:cluster_ip],
          :multicast_address => params[:multicast_address],
          :packages          => platform_params[:packages],
          #:set_votequorum    => platform_params[:set_votequorum],
          #:quorum_members    => params[:cluster_members],
        )

        is_expected.to contain_cs_property('pe-warn-series-max').with(
          :value => params[:pe_warn_series_max]
        )
        is_expected.to contain_cs_property('pe-input-series-max').with(
          :value => params[:pe_input_series_max]
        )
        is_expected.to contain_cs_property('pe-error-series-max').with(
          :value => params[:pe_error_series_max]
        )

        is_expected.to contain_corosync__service('pacemaker')
      end

      it 'configure pacemaker firewall rules' do
        is_expected.to contain_firewall('100 allow vrrp access').with(
          :port   => nil,
          :proto  => 'vrrp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow corosync tcp access').with(
          :port   => ['2224', '3121', '21064'],
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow corosync udp access').with(
          :port   => ['5404', '5405'],
          :proto  => 'udp',
          :action => 'accept',
        )
      end
    end

    context 'with two nodes only' do
      before :each do
        params.merge!(
          :cluster_members => ['node1', 'node2']
        )
      end

      it 'disables stonith and ignores votequorum errors' do
        is_expected.to contain_cs_property('no-quorum-policy').with(
          :value => 'ignore'
        )
        is_expected.to contain_cs_property('stonith-enabled').with(
          :value => 'false'
        )
      end
    end
  end

  shared_examples_for 'specific resources for RH platforms' do
    context 'with default parameters' do
      it { should contain_service('pacemaker').with(
        :ensure  => 'running',
        :enable  => true,
        :require => 'Class[Corosync]',
      )}

      it { should contain_service('pcsd').with(
        :ensure  => 'running',
        :enable  => true,
        :require => 'Class[Corosync]',
      )}
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :set_votequorum => false,
        :packages => ['corosync', 'pacemaker'] }
    end

    it_configures 'corosync and pacemaker'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :set_votequorum => true,
        :packages => ['corosync', 'pacemaker', 'pcs']}
    end

    it_configures 'corosync and pacemaker'
    it_configures 'specific resources for RH platforms'
  end
end
