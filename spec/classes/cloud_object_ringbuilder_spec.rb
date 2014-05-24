require 'spec_helper'

describe 'cloud::object::ringbuilder' do

  shared_examples_for 'openstack swift ringbuilder' do

    let :params do
      {
        :rsyncd_ipaddress           => '127.0.0.1',
        :replicas                    => 3,
        :swift_rsync_max_connections => 5,
      }
    end

    it 'create the three rings' do
      should contain_class('swift::ringbuilder').with({
        'part_power'     => '15',
        'replicas'       => '3',
        'min_part_hours' => '24',
      })
    end

    it 'create the ring rsync server' do
      should contain_class('swift::ringserver').with({
        'local_net_ip'    => '127.0.0.1',
        'max_connections' => '5',
      })
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack swift ringbuilder'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'openstack swift ringbuilder'
  end

end
