require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_variable_scope')
PuppetLint.configuration.send('disable_nested_classes_or_defines')
PuppetLint.configuration.send('disable_selector_inside_resource')
PuppetLint.configuration.ignore_paths = ['spec/fixtures/modules/**/*.pp']

task(:default).clear
task :default => [:spec_prep, :spec_standalone, :lint]

