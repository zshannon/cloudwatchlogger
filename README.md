Overview
--------

Send logged messages to [AWS CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/WhatIsCloudWatchLogs.html) using the ruby [AWS SDK](http://docs.aws.amazon.com/sdkforruby/api/index.html).

Can be used in place of Ruby's Logger
(<http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/>)

In fact, it (currently) returns an instance of Logger.

Forked from [loggiler](https://github.com/freeformz/logglier).

Usage
-----
```ruby
require 'cloudwatchlogger'

log = CloudWatchLogger.new({access_key_id: 'YOUR_ACCESS_KEY_ID', secret_access_key: 'YOUR_SECRET_ACCESS_KEY'}, 'YOUR_CLOUDWATCH_LOG_GROUP')

log.info("Hello World from Ruby")
```

In case you need to pass different region or group's different Log Stream name:

```ruby
log = CloudWatchLogger.new({
  access_key_id: 'YOUR_ACCESS_KEY_ID',
  secret_access_key: 'YOUR_SECRET_ACCESS_KEY'
}, 'YOUR_CLOUDWATCH_LOG_GROUP', 'YOUR_CLOUDWATCH_LOG_STREAM', region: 'YOUR_CLOUDWATCH_REGION' )
```

### With Rails

config/environments/production.rb
```ruby
RailsApplication::Application.configure do
  config.logger = CloudWatchLogger.new({access_key_id: 'YOUR_ACCESS_KEY_ID', secret_access_key: 'YOUR_SECRET_ACCESS_KEY'}, 'YOUR_CLOUDWATCH_LOG_GROUP')
end
```


### With Rails 4

config/initializers/cloudwatchlogger.rb
```ruby
cloudwatchlogger = CloudWatchLogger.new({access_key_id: 'YOUR_ACCESS_KEY_ID', secret_access_key: 'YOUR_SECRET_ACCESS_KEY'}, 'YOUR_CLOUDWATCH_LOG_GROUP')
Rails.logger.extend(ActiveSupport::Logger.broadcast(cloudwatchlogger))
```

Logging
-------

CloudWatchLogger.new returns a ruby Logger object, so take a look at:

http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/

The Logger's logdev has some special format handling though.

### Logging a string

```ruby
log.warn "test"
```

Will produce the following log message in CloudWatch Logs:

```
"<Date> severity=WARN, test"
```

### Logging a Hash

```ruby
log.warn :boom => :box, :bar => :soap
```

Will produce the following log message in CloudWatch Logs:

```
"<Date> severity=WARN, boom=box, bar=soap"
```

Releasing
-----

`rake release`

Bugs
-----

https://github.com/zshannon/cloudwatchlogger/issues

Pull requests welcome.
