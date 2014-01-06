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
# Unit tests for privatecloud::identity class
#

require 'spec_helper'

describe 'privatecloud::identity' do

  shared_examples_for 'openstack identity' do

    let :params do
      { :identity_roles_addons        => ['SwiftOperator', 'ResellerAdmin'],
        :keystone_db_host             => '10.0.0.1',
        :keystone_db_user             => 'keystone',
        :keystone_db_password         => 'secrete',
        :memcache_servers             => ['10.0.0.1','10.0.0.2'],
        :ks_admin_email               => 'admin@openstack.org',
        :ks_admin_password            => 'secrete',
        :ks_admin_tenant              => 'admin',
        :ks_admin_token               => 'SECRETE',
        :ks_ceilometer_admin_host     => '10.0.0.1',
        :ks_ceilometer_internal_host  => '10.0.0.1',
        :ks_ceilometer_password       => 'password',
        :ks_ceilometer_public_host    => '10.0.0.1',
        :ks_ceilometer_public_port    => '8777',
        :ks_ceilometer_public_proto   => 'http',
        :ks_cinder_admin_host         => '10.0.0.1',
        :ks_cinder_internal_host      => '10.0.0.1',
        :ks_cinder_password           => 'secrete',
        :ks_cinder_public_host        => '10.0.0.1',
        :ks_cinder_public_proto       => 'http',
        :ks_glance_admin_host         => '10.0.0.1',
        :ks_glance_internal_host      => '10.0.0.1',
        :ks_glance_password           => 'secrete',
        :ks_glance_public_host        => '10.0.0.1',
        :ks_glance_public_proto       => 'http',
        :ks_heat_admin_host           => '10.0.0.1',
        :ks_heat_internal_host        => '10.0.0.1',
        :ks_heat_password             => 'secrete',
        :ks_heat_public_host          => '10.0.0.1',
        :ks_heat_public_proto         => 'http',
        :ks_internal_ceilometer_port  => '8777',
        :ks_keystone_admin_host       => '10.0.0.1',
        :ks_keystone_admin_port       => '35357',
        :ks_keystone_internal_host    => '10.0.0.1',
        :ks_keystone_internal_port    => '5000',
        :ks_keystone_public_host      => '10.0.0.1',
        :ks_keystone_public_port      => '5000',
        :ks_keystone_public_proto     => 'http',
        :ks_neutron_admin_host        => '10.0.0.1',
        :ks_neutron_internal_host     => '10.0.0.1',
        :ks_neutron_password          => 'secrete',
        :ks_neutron_public_host       => '10.0.0.1',
        :ks_neutron_public_proto      => 'http',
        :ks_nova_admin_host           => '10.0.0.1',
        :ks_nova_internal_host        => '10.0.0.1',
        :ks_nova_password             => 'secrete',
        :ks_nova_public_host          => '10.0.0.1',
        :ks_nova_public_proto         => 'http',
        :ks_swift_dispersion_password => 'secrete',
        :ks_swift_internal_host       => '10.0.0.1',
        :ks_swift_internal_port       => '10.0.0.1',
        :ks_swift_password            => 'secrete',
        :ks_swift_public_host         => '10.0.0.1',
        :ks_swift_public_port         => '8080',
        :ks_swift_public_proto        => 'http',
        :region                       => 'BigCloud',
        :verbose                      => true,
        :debug                        => true,
        :api_eth                      => '10.0.0.1' }
    end

    it 'configure keystone server' do
      should contain_class('keystone').with(
      )
    end

    it 'configure keystone admin role' do
      should contain_class('keystone::roles::admin').with(
      )
    end

    it 'configure apache to run keystone with wsgi' do
      should contain_class('keystone::wsgi::apache').with(
      )
    end

    it 'configure keystone endpoint' do
      should contain_class('keystone::endpoint').with(
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

#    it_configures 'openstack identity'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

#    it_configures 'openstack identity'
  end

end
