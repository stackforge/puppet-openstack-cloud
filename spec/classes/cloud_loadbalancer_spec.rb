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
# Unit tests for cloud::loadbalancer class
#

require 'spec_helper'

describe 'cloud::loadbalancer' do

  shared_examples_for 'openstack master loadbalancer' do

    let :params do
      { :ceilometer_api                 => true,
        :cinder_api                     => true,
        :glance_api                     => true,
        :neutron_api                    => true,
        :heat_api                       => true,
        :heat_cfn_api                   => true,
        :heat_cloudwatch_api            => true,
        :nova_api                       => true,
        :ec2_api                        => true,
        :metadata_api                   => true,
        :swift_api                      => true,
        :keystone_api_admin             => true,
        :keystone_api                   => true,
        :horizon                        => true,
        :spice                          => true,
        :haproxy_auth                   => 'root:secrete',
        :keepalived_state               => 'MASTER',
        :keepalived_priority            => 50,
        :keepalived_interface           => 'eth0',
        :keepalived_ipvs                => ['10.0.0.1', '10.0.0.2'],
        :keepalived_localhost_ip        => '127.0.0.1',
        :horizon_port                   => '80',
        :spice_port                     => '6082',
        :openstack_vip                  => '10.0.0.3',
        :mysql_vip                      => '10.0.0.4',
        :ks_ceilometer_public_port      => '8777',
        :ks_nova_public_port            => '8774',
        :ks_ec2_public_port             => '8773',
        :ks_metadata_public_port        => '8777',
        :ks_glance_public_port          => '9292',
        :ks_swift_public_port           => '8080',
        :ks_keystone_public_port        => '5000',
        :ks_keystone_admin_port         => '35357',
        :ks_cinder_public_port          => '8776',
        :ks_neutron_public_port         => '9696',
        :ks_heat_public_port            => '8004',
        :ks_heat_cfn_public_port        => '8000',
        :ks_heat_cloudwatch_public_port => '8003' }
    end

    it 'configure haproxy server' do
      should contain_class('haproxy').with({
        'manage_service' => 'false',
      })
    end

    it 'configure keepalived server' do
      should contain_class('keepalived')
    end

    it 'configure vrrp_instance with MASTER state' do
      should contain_keepalived__instance('1').with({
        'state'         => 'MASTER',
        'priority'      => 50,
        'notify_master' => '"/etc/init.d/haproxy start"',
        'notify_backup' => '"/etc/init.d/haproxy stop"',
      })
    end

  end

  shared_examples_for 'openstack backup loadbalancer' do

    let :params do
      { :ceilometer_api                 => true,
        :cinder_api                     => true,
        :glance_api                     => true,
        :neutron_api                    => true,
        :heat_api                       => true,
        :heat_cfn_api                   => true,
        :heat_cloudwatch_api            => true,
        :nova_api                       => true,
        :ec2_api                        => true,
        :metadata_api                   => true,
        :swift_api                      => true,
        :keystone_api_admin             => true,
        :keystone_api                   => true,
        :horizon                        => true,
        :spice                          => true,
        :haproxy_auth                   => 'root:secrete',
        :keepalived_state               => 'BACKUP',
        :keepalived_priority            => 49,
        :keepalived_interface           => 'eth0',
        :keepalived_ipvs                => ['10.0.0.1', '10.0.0.2'],
        :keepalived_localhost_ip        => '127.0.0.1',
        :horizon_port                   => '80',
        :spice_port                     => '6082',
        :openstack_vip                  => '10.0.0.3',
        :mysql_vip                      => '10.0.0.4',
        :ks_ceilometer_public_port      => '8777',
        :ks_nova_public_port            => '8774',
        :ks_ec2_public_port             => '8773',
        :ks_metadata_public_port        => '8777',
        :ks_glance_public_port          => '9292',
        :ks_swift_public_port           => '8080',
        :ks_keystone_public_port        => '5000',
        :ks_keystone_admin_port         => '35357',
        :ks_cinder_public_port          => '8776',
        :ks_neutron_public_port         => '9696',
        :ks_heat_public_port            => '8004',
        :ks_heat_cfn_public_port        => '8000',
        :ks_heat_cloudwatch_public_port => '8003' }
    end

    it 'configure haproxy server' do
      should contain_class('haproxy').with({
        'manage_service' => 'false',
      })
    end

    it 'configure keepalived server' do
      should contain_class('keepalived')
    end

    it 'configure vrrp_instance with BACKUP state' do
      should contain_keepalived__instance('1').with({
        'priority'      => '49',
        'notify_master' => '"/etc/init.d/haproxy start"',
        'notify_backup' => '"/etc/init.d/haproxy stop"',
      })
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack master loadbalancer'
    it_configures 'openstack backup loadbalancer'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack master loadbalancer'
    it_configures 'openstack backup loadbalancer'
  end

end
