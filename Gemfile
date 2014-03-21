source 'https://rubygems.org'

gem 'puppetlabs_spec_helper'
gem 'puppet-lint'
gem 'json'
gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
gem 'rake'
gem 'puppet-syntax'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
