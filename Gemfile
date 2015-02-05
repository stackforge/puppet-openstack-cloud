source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint-param-docs'
  gem 'metadata-json-lint'
  gem 'json'
  gem 'webmock'
  gem 'r10k'
  gem 'librarian-puppet-simple', '~> 0.0.3'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
