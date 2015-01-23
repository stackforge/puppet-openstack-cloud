
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
# Spec tests for cloud::clustering::pacemaker_colocation

require 'spec_helper'

describe 'cloud::clustering::pacemaker_colocation', :type => :define do

  let (:title) { 'service1' }

  let :params do
    {
        :service        => 'service1',
        :colocated_with => ['service2','service3']
    }
  end

  context 'with default parameters' do
    it 'should create a colocation constraint' do
        should contain_cs_colocation('service1-with-service2').with(
          {
            'primitives' => ["p_service1", "p_service2"],
          }
        )

        should contain_cs_colocation('service1-with-service3').with(
          {
            'primitives' => ["p_service1", "p_service3"],
          }
        )
    end
  end
end
