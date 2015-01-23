require 'spec_helper'

describe 'cloud::install::puppetdb::server' do

  shared_examples_for 'puppetdb' do

    it 'install puppetdb' do
      is_expected.to contain_class('puppetdb')
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '7.4'}
    end

    it_configures 'puppetdb'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '7.0'}
    end

    it_configures 'puppetdb'
  end
end
