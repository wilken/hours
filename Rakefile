#!/usr/bin/env rake
require "rspec/core/rake_task"

ENV['RACK_ENV'] = 'test'

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec