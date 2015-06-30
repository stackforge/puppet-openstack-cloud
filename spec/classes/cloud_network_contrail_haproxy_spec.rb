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
# Unit tests for cloud::network::contrail::haproxy
#

require 'spec_helper'

describe 'cloud::network::contrail::haproxy' do

  shared_examples_for 'contrail-haproxy stanzas' do

    let :params do
      { }
    end

    it { is_expected.to contain_cloud__loadbalancer__binding('contrail_analytics_api').with(
      :port => '8081'
    )}

    it { is_expected.to contain_cloud__loadbalancer__binding('contrail_config_api').with(
      :port => '8082'
    )}

    it { is_expected.to contain_cloud__loadbalancer__binding('contrail_config_discovery').with(
      :port => '5998'
    )}

    it { is_expected.to contain_cloud__loadbalancer__binding('contrail_webui_http').with(
      :port => '8079'
    )}

    it { is_expected.to contain_cloud__loadbalancer__binding('contrail_webui_https').with(
      :port => '8143'
    )}
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

    it_configures 'contrail-haproxy stanzas'
  end

end
