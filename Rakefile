require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
# for manifest loadbalancer.pp +39 (default value as an array of variables)
PuppetLint.configuration.send('disable_class_parameter_defaults')
# For stonith-enabled (it's a string not a bool)
PuppetLint.configuration.send('disable_quoted_booleans')
# Ignore all upstream modules
PuppetLint.configuration.ignore_paths = ['spec/fixtures/modules/**/*.pp']

task(:default).clear
task :default => [:spec_prep, :spec_standalone, :lint]
