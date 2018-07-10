require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.expand_path('../lib/cloudwatchlogger/version', __FILE__)

desc 'Builds the gem'
task :build do
  sh "gem build cloudwatchlogger.gemspec"
end

desc 'Builds and installs the gem'
task :install => :build do
  sh "gem install cloudwatchlogger-#{CloudWatchLogger::VERSION}"
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh "git tag v#{CloudWatchLogger::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{CloudWatchLogger::VERSION}"
  sh "gem push cloudwatchlogger-#{CloudWatchLogger::VERSION}.gem"
end
