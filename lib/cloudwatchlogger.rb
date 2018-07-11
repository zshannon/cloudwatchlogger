require File.join(File.dirname(__FILE__), 'cloudwatchlogger', 'client')

require 'logger'

module CloudWatchLogger
  class LogGroupNameRequired < ArgumentError; end
  class LogEventRejected < ArgumentError; end

  def self.new(credentials, log_group_name, log_stream_name = nil, opts = {})
    client = CloudWatchLogger::Client.new(credentials, log_group_name, log_stream_name, opts)
    logger = Logger.new(client)

    if client.respond_to?(:formatter)
      logger.formatter = client.formatter
    elsif client.respond_to?(:datetime_format)
      logger.datetime_format = client.datetime_format
    end

    logger
  end
end
