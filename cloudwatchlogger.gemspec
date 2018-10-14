dir = File.dirname(__FILE__)
require File.expand_path(File.join(dir, 'lib', 'cloudwatchlogger', 'version'))

Gem::Specification.new do |s|
  s.name              = 'cloudwatchlogger'
  s.version           = CloudWatchLogger::VERSION
  s.date              = Time.now
  s.summary           = 'Amazon CloudWatch Logs compatiable logger for ruby.'
  s.description       = 'Logger => CloudWatchLogs'

  s.license           = "MIT"

  s.authors           = ["Zane Shannon"]
  s.email             = 'z@zcs.me'
  s.homepage          = 'http://github.com/zshannon/cloudwatchlogger'

  s.files             = %w{ README.md Gemfile LICENSE cloudwatchlogger.gemspec } + Dir["lib/**/*.rb"]
  s.require_paths     = ['lib']
  s.test_files        = Dir["spec/**/*.rb"]

  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_runtime_dependency 'uuid', '~> 2'
  s.add_runtime_dependency 'multi_json', '~> 1'
  s.add_runtime_dependency 'aws-sdk-cloudwatchlogs', '~> 1'
end
