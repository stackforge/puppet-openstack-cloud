require 'spec_helper'

describe 'cloud::install::puppetdb::config' do

  shared_examples_for 'puppetdb' do

    it 'configure puppetdb' do
      is_expected.to contain_class('puppetdb::master::config')
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'puppetdb'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'puppetdb'
  end
end
