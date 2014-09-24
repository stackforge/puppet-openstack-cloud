source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint', '~> 0.3.2'
  gem 'rake', '10.1.1'
  gem 'puppet-syntax'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  # rspec-puppet fetch the latest rspec (3.0.0)
  # this version is a bit incompat. with older specs...
  # http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3
  gem 'rspec', '< 2.99'
  gem 'json'
  gem 'webmock'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
