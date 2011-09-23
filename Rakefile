require 'rake'
require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

desc "Run all the tests we have"
task :all => [:spec]

task :default => :all

