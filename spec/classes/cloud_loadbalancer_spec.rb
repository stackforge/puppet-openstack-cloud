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

  shared_examples_for 'openstack loadbalancer' do

    let :params do
      { :ceilometer_api                    => true,
        :cinder_api                        => true,
        :glance_api                        => true,
        :neutron_api                       => true,
        :heat_api                          => true,
        :heat_cfn_api                      => true,
        :heat_cloudwatch_api               => true,
        :nova_api                          => true,
        :ec2_api                           => true,
        :metadata_api                      => true,
        :swift_api                         => true,
        :keystone_api_admin                => true,
        :keystone_api                      => true,
        :horizon                           => true,
        :horizon_ssl                       => false,
        :spice                             => true,
        :haproxy_auth                      => 'root:secrete',
        :keepalived_state                  => 'BACKUP',
        :keepalived_priority               => 50,
        :keepalived_public_interface       => 'eth0',
        :keepalived_public_ipvs            => ['10.0.0.1', '10.0.0.2'],
        :horizon_port                      => '80',
        :spice_port                        => '6082',
        :vip_public_ip                     => '10.0.0.1',
        :galera_ip                         => '10.0.0.2',
        :ks_ceilometer_public_port         => '8777',
        :ks_nova_public_port               => '8774',
        :ks_ec2_public_port                => '8773',
        :ks_metadata_public_port           => '8777',
        :ks_glance_api_public_port         => '9292',
        :ks_glance_registry_internal_port  => '9191',
        :ks_swift_public_port              => '8080',
        :ks_keystone_public_port           => '5000',
        :ks_keystone_admin_port            => '35357',
        :ks_cinder_public_port             => '8776',
        :ks_neutron_public_port            => '9696',
        :ks_heat_public_port               => '8004',
        :ks_heat_cfn_public_port           => '8000',
        :ks_heat_cloudwatch_public_port    => '8003' }
    end

    it 'configure haproxy server' do
      should contain_class('haproxy')
    end # configure haproxy server

    it 'configure keepalived server' do
      should contain_class('keepalived')
    end # configure keepalived server

    context 'configure an internal VIP' do
      before do
        params.merge!(:keepalived_internal_ipvs => ['192.168.0.1'])
      end
      it 'configure an internal VRRP instance' do
        should contain_keepalived__instance('2').with({
          'interface'     => 'eth1',
          'virtual_ips'   => ['192.168.0.1 dev eth1'],
          'track_script'  => ['haproxy'],
          'state'         => 'BACKUP',
          'priority'      => params[:keepalived_priority],
          'notify_master' => '"/etc/init.d/haproxy start"',
          'notify_backup' => '"/etc/init.d/haproxy stop"',
        })
      end
    end

    context 'configure keepalived with deprecated parameters' do
      before do
        params.merge!(
          :keepalived_ipvs      => ['192.168.0.2'],
          :vip_public_ip        => '192.168.0.2',
          :galera_ip            => '192.168.0.2',
          :keepalived_interface => 'eth3'
        )
      end
      it 'configure a public VRRP instance with deprecated parameters' do
        should contain_keepalived__instance('1').with({
          'interface'     => 'eth3',
          'virtual_ips'   => ['192.168.0.2 dev eth3'],
          'track_script'  => ['haproxy'],
          'state'         => 'BACKUP',
          'priority'      => params[:keepalived_priority],
          'notify_master' => '"/etc/init.d/haproxy start"',
          'notify_backup' => '"/etc/init.d/haproxy stop"',
        })
      end
    end

    context 'configure keepalived in backup' do
      it 'configure vrrp_instance with BACKUP state' do
        should contain_keepalived__instance('1').with({
          'interface'     => params[:keepalived_public_interface],
          'virtual_ips'   => ['10.0.0.1 dev eth0', '10.0.0.2 dev eth0'],
          'track_script'  => ['haproxy'],
          'state'         => params[:keepalived_state],
          'priority'      => params[:keepalived_priority],
          'notify_master' => '"/etc/init.d/haproxy start"',
          'notify_backup' => '"/etc/init.d/haproxy stop"',
        })
      end # configure vrrp_instance with BACKUP state
    end # configure keepalived in backup

    context 'configure keepalived in master' do
      before do
        params.merge!( :keepalived_state => 'MASTER' )
      end
      it 'configure vrrp_instance with MASTER state' do
        should contain_keepalived__instance('1').with({
          'interface'     => params[:keepalived_public_interface],
          'track_script'  => ['haproxy'],
          'state'         => 'MASTER',
          'priority'      => params[:keepalived_priority],
          'notify_master' => '"/etc/init.d/haproxy start"',
          'notify_backup' => '"/etc/init.d/haproxy stop"',
        })
      end
    end # configure keepalived in master

    context 'configure logrotate file' do
      it { should contain_file('/etc/logrotate.d/haproxy').with(
        :source => 'puppet:///modules/cloud/logrotate/haproxy',
        :mode   => '0644',
        :owner  => 'root',
        :group  => 'root'
      )}
    end # configure logrotate file

    context 'configure monitor haproxy listen' do
      it { should contain_haproxy__listen('monitor').with(
        :ipaddress => params[:vip_public_ip],
        :ports     => '9300'
      )}
    end # configure monitor haproxy listen

    context 'configure monitor haproxy listen' do
      it { should contain_haproxy__listen('galera_cluster').with(
        :ipaddress => params[:galera_ip],
        :ports     => '3306',
        :options   => {
          'mode'           => 'tcp',
          'balance'        => 'roundrobin',
          'option'         => ['tcpka','tcplog','httpchk'],
          'timeout client' => '400s',
          'timeout server' => '400s'
        }
      )}
    end # configure monitor haproxy listen

    # test backward compatibility
    context 'configure OpenStack binding on public network only' do
      it { should contain_haproxy__listen('spice_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '6082'
      )}
    end

    context 'configure OpenStack binding on both public and internal networks' do
      before do
        params.merge!(
          :nova_api               => true,
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => '172.16.0.1',
          :vip_internal_ip        => '192.168.0.1',
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2'],
          :keepalived_internal_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it { should contain_haproxy__listen('nova_api_cluster').with(
        :ipaddress => ['172.16.0.1', '192.168.0.1'],
        :ports     => '8774'
      )}
    end

    context 'disable an OpenStack service binding' do
      before do
        params.merge!(:metadata_api => false)
      end
      it { should_not contain_haproxy__listen('metadata_api_cluster') }
    end

    context 'should fail to configure OpenStack binding when vip_public_ip and vip_internal_ip are missing' do
      before do
        params.merge!(
          :nova_api               => true,
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => false,
          :vip_internal_ip        => false,
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_public_ip and vip_internal_ip are both set to false, no binding is possible./
    end

    context 'should fail to configure OpenStack binding when given VIP is not in the VIP pool list' do
      before do
        params.merge!(
          :nova_api               => '10.0.0.1',
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => '172.16.0.1',
          :vip_internal_ip        => false,
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2']
        )
      end
      it_raises 'a Puppet::Error', /10.0.0.1 is not part of VIP pools./
    end

    context 'with a public OpenStack VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :vip_public_ip          => '172.16.0.1',
          :keepalived_public_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_public_ip should be part of keepalived_public_ipvs./
    end

    context 'with an internal OpenStack VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :vip_internal_ip          => '172.16.0.1',
          :keepalived_internal_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_internal_ip should be part of keepalived_internal_ipvs./
    end

    context 'with a Galera VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :galera_ip                => '172.16.0.1',
          :vip_public_ip            => '192.168.0.1',
          :keepalived_public_ipvs   => ['192.168.0.1', '192.168.0.2'],
          :keepalived_internal_ipvs => ['192.168.1.1', '192.168.1.2']
        )
      end
      it_raises 'a Puppet::Error', /galera_ip should be part of keepalived_public_ipvs or keepalived_internal_ipvs./
    end

  end # shared:: openstack loadbalancer

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack loadbalancer'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :concat_basedir => '/var/lib/puppet/concat' }
    end

    it_configures 'openstack loadbalancer'
  end

end
