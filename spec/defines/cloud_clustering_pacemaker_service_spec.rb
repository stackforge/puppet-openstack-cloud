
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
# Spec tests for cloud::clustering::pacemaker_service

require 'spec_helper'

describe 'cloud::clustering::pacemaker_service', :type => :define do

  let :pre_condition do
    "service { ['foo-api','bar-api']:
       ensure => running
    }"
  end

  let (:title) { 'foo-api' }

  let :params do
    {
        :service_name       => 'foo-api',
        :primitive_class    => 'systemd',
        :primitive_provider => false,
        :primitive_type     => 'foo-api',
        :clone              => false,
        :colocated_services => [],
        :start_after        => [],
        :requires           => []
    }
  end

  context 'with default parameters' do
    it 'should create a Pacemaker service' do
      should contain_openstack_extras__pacemaker__service('foo-api').with(
        {
          'ensure'             => :present,
          'primitive_class'    => params[:primitive_class],
          'primitive_provider' => params[:primitive_provider],
          'primitive_type'     => params[:primitive_type],
          'clone'              => params[:clone],
          'require'            => params[:requires]
        }
      )
    end
  end

  context 'with colocated services and start ordering' do
    before :each do
      params.merge!(
        :colocated_services => ["bar-api"],
        :start_after        => ["foo-api"],
      )
    end

    it 'creates a colocation constraint' do
      is_expected.to contain_cloud__clustering__pacemaker_colocation('foo-api')
    end

    it 'creates an order constraint' do
      is_expected.to contain_cloud__clustering__pacemaker_order('foo-api')
    end
  end

  context 'with clone=true' do
    before :each do
      params.merge!(
        :clone => true,
      )
    end

    it 'creates a cloned resource' do
      is_expected.to contain_openstack_extras__pacemaker__service('foo-api').with(
        {
          'clone' => :true
        }
      )
    end
  end

end
