
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
# Spec tests for cloud::clustering::pacemaker_order

require 'spec_helper'

describe 'cloud::clustering::pacemaker_order', :type => :define do

  let (:title) { 'service1,service2' }

  context 'with default parameters' do
    it 'should create an order constraint' do
        should contain_cs_order('service1-before-service2').with(
          {
            'first'  => "p_service1",
            'second' => "p_service2"
          }
        )
    end
  end
end
