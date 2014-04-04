# -*- mode: ruby -*-
# vi: set ft=ruby :
#
NAME = 'enovance-cloud'
TDIR = File.expand_path(File.dirname(__FILE__))

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
# for manifest loadbalancer.pp +39 (default value as an array of variables)
PuppetLint.configuration.send('disable_class_parameter_defaults')
# For stonith-enabled (it's a string not a bool)
PuppetLint.configuration.send('disable_quoted_booleans')
# Ignore all upstream modules
exclude_paths = ['spec/**/*','pkg/**/*','vendor/**/*']
exclude_lint_paths = exclude_paths + ['examples/*.pp']

PuppetLint.configuration.ignore_paths = exclude_lint_paths
PuppetSyntax.exclude_paths = exclude_paths


task(:default).clear
task :default => :test

desc 'Run syntax, lint and spec tests'
task :test => [:syntax,:lint,:spec]

desc 'Run syntax, lint and spec tests (without fixture purge = train/airplane)'
task :test_keep => [:syntax,:lint,:spec_prep,:spec_standalone]

if ENV['COV']
  desc 'Run syntax, lint, spec tests and coverage'
  task :cov => [:syntax,:lint,:spec_prep,:spec_standalone]
end

namespace :module do
  desc "Build #{NAME} module (in a clean env) Please use this for puppetforge"
  task :build do
    exec "rsync -rv --exclude-from=#{TDIR}/.forgeignore . /tmp/#{NAME};cd /tmp/#{NAME};puppet module build"
  end
end
