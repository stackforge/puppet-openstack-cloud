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
# Unit tests for cloud::identity class
#

require 'spec_helper'

describe 'cloud::identity' do

  shared_examples_for 'openstack identity' do

    let :params do
      { :identity_roles_addons        => ['SwiftOperator', 'ResellerAdmin'],
        :swift_enabled                => true,
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
        :ks_ceilometer_password       => 'secrete',
        :ks_ceilometer_public_host    => '10.0.0.1',
        :ks_ceilometer_public_port    => '8777',
        :ks_ceilometer_public_proto   => 'http',
        :ks_cinder_admin_host         => '10.0.0.1',
        :ks_cinder_internal_host      => '10.0.0.1',
        :ks_cinder_password           => 'secrete',
        :ks_cinder_public_host        => '10.0.0.1',
        :ks_cinder_public_proto       => 'http',
        :ks_cinder_public_port        => '8776',
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
        :ks_heat_public_port          => '8004',
        :ks_heat_cfn_public_port      => '8000',
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
        :ks_neutron_public_port       => '9696',
        :ks_nova_admin_host           => '10.0.0.1',
        :ks_nova_internal_host        => '10.0.0.1',
        :ks_nova_password             => 'secrete',
        :ks_nova_public_host          => '10.0.0.1',
        :ks_nova_public_proto         => 'http',
        :ks_nova_public_port          => '8774',
        :ks_ec2_public_port           => '8773',
        :ks_swift_dispersion_password => 'secrete',
        :ks_swift_internal_host       => '10.0.0.1',
        :ks_swift_password            => 'secrete',
        :ks_swift_public_host         => '10.0.0.1',
        :ks_swift_public_port         => '8080',
        :ks_swift_public_proto        => 'http',
        :ks_swift_admin_host          => '10.0.0.1',
        :region                       => 'BigCloud',
        :verbose                      => true,
        :debug                        => true,
        :log_facility                 => 'LOG_LOCAL0',
        :use_syslog                   => true,
        :api_eth                      => '10.0.0.1' }
    end

    it 'configure keystone server' do
      should contain_class('keystone').with(
        :enabled             => true,
        :admin_token         => 'SECRETE',
        :compute_port        => '8774',
        :debug               => true,
        :verbose             => true,
        :idle_timeout        => '60',
        :log_facility        => 'LOG_LOCAL0',
        :memcache_servers    => ['10.0.0.1','10.0.0.2'],
        :sql_connection      => 'mysql://keystone:secrete@10.0.0.1/keystone',
        :token_driver        => 'keystone.token.backends.memcache.Token',
        :token_provider      => 'keystone.token.providers.uuid.Provider',
        :use_syslog          => true,
        :bind_host           => '10.0.0.1',
        :public_port         => '5000',
        :admin_port          => '35357',
        :ks_token_expiration => '3600'
      )
      should contain_keystone_config('ec2/driver').with('value' => 'keystone.contrib.ec2.backends.sql.Ec2')
    end

    it 'checks if Keystone DB is populated' do
      should contain_exec('keystone_db_sync').with(
        :command => '/usr/bin/keystone-manage db_sync',
        :unless  => '/usr/bin/mysql keystone -h 10.0.0.1 -u keystone -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure keystone admin role' do
      should contain_class('keystone::roles::admin').with(
        :email        => 'admin@openstack.org',
        :password     => 'secrete',
        :admin_tenant => 'admin'
      )
    end

    # TODO(EmilienM) Disable WSGI - bug #98
    #  it 'configure apache to run keystone with wsgi' do
    #    should contain_class('keystone::wsgi::apache').with(
    #      :servername  => 'keystone.openstack.org',
    #      :admin_port  => '35357',
    #      :public_port => '5000',
    #      :workers     => '2',
    #      :ssl         => false
    #    )
    #  end

    it 'configure keystone endpoint' do
      should contain_class('keystone::endpoint').with(
        :admin_address    => '10.0.0.1',
        :admin_port       => '35357',
        :internal_address => '10.0.0.1',
        :internal_port    => '5000',
        :public_address   => '10.0.0.1',
        :public_port      => '5000',
        :public_protocol  => 'http',
        :region           => 'BigCloud'
      )
    end

    it 'configure swift endpoints' do
      should contain_class('swift::keystone::auth').with(
        :address          => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_port      => '8080',
        :public_protocol  => 'http',
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :region           => 'BigCloud'
      )
    end

    it 'configure swift dispersion' do
      should contain_class('swift::keystone::dispersion').with( :auth_pass => 'secrete' )
    end

    it 'configure ceilometer endpoints' do
      should contain_class('ceilometer::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :port             => '8777',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :region           => 'BigCloud'
      )
    end

    it 'configure nova endpoints' do
      should contain_class('nova::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :cinder           => true,
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :compute_port     => '8774',
        :ec2_port         => '8773',
        :region           => 'BigCloud'
      )
    end

    it 'configure neutron endpoints' do
      should contain_class('neutron::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :port             => '9696',
        :region           => 'BigCloud'
      )
    end

    it 'configure cinder endpoints' do
      should contain_class('cinder::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :region           => 'BigCloud'
      )
    end

    it 'configure glance endpoints' do
      should contain_class('glance::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :port             => '9292',
        :region           => 'BigCloud'
      )
    end

    it 'configure heat endpoints' do
      should contain_class('heat::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :port             => '8004',
        :region           => 'BigCloud'
      )
    end

    it 'configure heat cloudformation endpoints' do
      should contain_class('heat::keystone::auth_cfn').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'http',
        :port             => '8000',
        :region           => 'BigCloud'
      )
    end

    context 'without Swift' do
      before :each do
        params.merge!(:swift_enabled => false)
      end
      it 'should not configure swift endpoints and users' do
        should_not contain_class('swift::keystone::auth')
        should_not contain_class('swift::keystone::dispersion')
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '12.04',
        :processorcount         => '2',
        :concat_basedir         => '/var/lib/puppet/concat',
        :fqdn                   => 'keystone.openstack.org' }
    end

    it_configures 'openstack identity'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :processorcount         => '2',
        :concat_basedir         => '/var/lib/puppet/concat',
        :fqdn                   => 'keystone.openstack.org' }
    end

    it_configures 'openstack identity'
  end

end
