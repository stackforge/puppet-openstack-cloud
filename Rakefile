# -*- mode: ruby -*-
# vi: set ft=ruby :
#
NAME = 'eNovance-cloud'
TDIR = File.expand_path(File.dirname(__FILE__))

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
# for manifest loadbalancer.pp +39 (default value as an array of variables)
PuppetLint.configuration.send('disable_class_parameter_defaults')
# manifests/image/api.pp - WARNING: string containing only a variable on line 189
PuppetLint.configuration.send('disable_only_variable_string')
# For stonith-enabled (it's a string not a bool)
PuppetLint.configuration.send('disable_quoted_booleans')
# Ignore all upstream modules
exclude_paths = ['spec/**/*','pkg/**/*','vendor/**/*']
exclude_lint_paths = exclude_paths

PuppetLint.configuration.ignore_paths = exclude_lint_paths
PuppetSyntax.exclude_paths = exclude_paths


task(:default).clear
task :default => :test

desc 'Run syntax, lint and spec tests'
task :test => [:syntax,:lint,:validate_puppetfile,:validate_metadata_json,:spec]

desc 'Run syntax, lint and spec tests (without fixture purge = train/airplane)'
task :test_keep => [:syntax,:lint,:validate_puppetfile,:validate_metadata_json,:spec_prep,:spec_standalone]

if ENV['COV']
  desc 'Run syntax, lint, spec tests and coverage'
  task :cov => [:syntax,:lint,:validate_puppetfile,:validate_metadata_json,:spec_prep,:spec_standalone]
end

desc "Validate the Puppetfile syntax"
task :validate_puppetfile do
  $stderr.puts "---> syntax:puppetfile"
  sh "r10k puppetfile check"
end

desc "Validate the metadata.json syntax"
task :validate_metadata_json do
  $stderr.puts "---> syntax:metadata.json"
  sh "metadata-json-lint metadata.json"
end

namespace :module do
  desc "Build #{NAME} module (in a clean env) Please use this for puppetforge"
  task :build do
    exec "rsync -rv --exclude-from=#{TDIR}/.forgeignore . /tmp/#{NAME};cd /tmp/#{NAME};puppet module build"
  end
end
