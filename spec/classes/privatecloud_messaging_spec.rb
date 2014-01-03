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
# Unit tests for privatecloud::messaging class
#

require 'spec_helper'

describe 'privatecloud::messaging' do

  shared_examples_for 'openstack messaging' do

    let :params do
      { :rabbit_hosts    => ['10.0.0.1'],
        :rabbit_password => 'secrete' }
    end

    it 'configure rabbitmq-server' do
      should contain_class('rabbitmq::server').with(
          :delete_guest_user        => true,
          :config_cluster           => true,
          :cluster_nodes            => ['10.0.0.1'],
          :wipe_db_on_cookie_change => true
        )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack messaging'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack messaging'
  end

end
