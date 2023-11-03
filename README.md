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

The region will default to the value of the environment variable `AWS_REGION`. In case you need to pass different region or group's different Log Stream name:

```ruby
log = CloudWatchLogger.new({
  access_key_id: 'YOUR_ACCESS_KEY_ID',
  secret_access_key: 'YOUR_SECRET_ACCESS_KEY'
}, 'YOUR_CLOUDWATCH_LOG_GROUP', 'YOUR_CLOUDWATCH_LOG_STREAM', region: 'YOUR_CLOUDWATCH_REGION' )
```

Providing an empty hash instead of credentials will cause the AWS SDK to search the default credential provider chain for credentials, namely:

1. Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
1. Amazon ECS container credentials (task role)
1. Instance profile credentials (IAM role)

Besides the AWS region, you can also specify some other configuration options for your logger, such as:

| Property        | Description                                                                          |
|-----------------|--------------------------------------------------------------------------------------|
| `region`        | AWS region.                                                                          |
| `format`        | The output format of your messages. `:json` generates JSON logs for hashed messages. |
| `open_timeout`  | The open timeout in seconds. Defaults to 120.                                        |
| `read_timeout`  | The read timeout in seconds. Defaults to 120.                                        |

This way, you could have something like this:

```ruby
log = CloudWatchLogger.new({
    access_key_id: 'YOUR_ACCESS_KEY_ID',
    secret_access_key: 'YOUR_SECRET_ACCESS_KEY'
  }, 'YOUR_CLOUDWATCH_LOG_GROUP', 'YOUR_CLOUDWATCH_LOG_STREAM',
  {
    region: 'YOUR_CLOUDWATCH_REGION',
    format: :json
  })
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

### Custom Log Formatters
The default formatter in this gem ensures that the timestamp sent to cloudwatch will reflect the time the message was pushed onto the queue. If you want to use a custom log formatter, in order for you to not have a disparity between your actual log time and the time reflected in CloudWatch, you will need to ensure your formatter is a `Hash` with a key for `message` which will contain your log message, and `epoch_time` which should be an epoch time formatted timestamp for your log entry, like so:

```ruby
logger.formatter = proc do |severity, datetime, progname, msg|
  {
    message:    "CUSTOM FORMATTER PREFIX: #{msg}\n",
    epoch_time: (datetime.utc.to_f.round(3) * 1000).to_i
  }
end
```

Releasing
-----

`rake release`

Bugs
-----

https://github.com/zshannon/cloudwatchlogger/issues

Pull requests welcome.
