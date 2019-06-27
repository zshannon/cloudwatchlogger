require 'multi_json'
require 'socket'
require 'thread'
require 'uuid'

module CloudWatchLogger
  module Client
    def self.new(credentials, log_group_name, log_stream_name = nil, opts = {})
      unless log_group_name
        raise LogGroupNameRequired, 'log_group_name is required'
      end

      CloudWatchLogger::Client::AWS_SDK.new(credentials, log_group_name, log_stream_name, opts)
    end

    module InstanceMethods
      def masherize_key(prefix, key)
        [prefix, key.to_s].compact.join('.')
      end

      def masher(hash, prefix = nil)
        hash.map do |v|
          if v[1].is_a?(Hash)
            masher(v[1], masherize_key(prefix, v[0]))
          else
            "#{masherize_key(prefix, v[0])}=" << case v[1]
                                                 when Symbol
                                                   v[1].to_s
                                                 else
                                                   v[1].inspect
                                                 end
          end
        end.join(', ')
      end

      def formatter
        proc do |severity, datetime, progname, msg|
          processid = Process.pid
          if @format == :json && msg.is_a?(Hash)
            message = MultiJson.dump(msg.merge(severity: severity,
                                     datetime: datetime,
                                     progname: progname,
                                     pid: processid))
          else
            message = "#{datetime} "
            message << massage_message(msg, severity, processid)
          end

          {
            message:    message,
            epoch_time: epoch_from(datetime)
          }
        end
      end

      def massage_message(incoming_message, severity, processid)
        outgoing_message = ''

        outgoing_message << "pid=#{processid}, thread=#{Thread.current.object_id}, severity=#{severity}, "

        outgoing_message << case incoming_message
                            when Hash
                              masher(incoming_message)
                            when String
                              incoming_message
                            else
                              incoming_message.inspect
                            end
        outgoing_message
      end

      def setup_credentials(credentials)
        @credentials = credentials
      end

      def setup_log_group_name(name)
        @log_group_name = name
      end

      def setup_log_stream_name(name)
        @log_stream_name = name || default_log_stream_name
      end

      def default_log_stream_name
        uuid = UUID.new
        @log_stream_name ||= "#{Socket.gethostname}-#{uuid.generate}"
      end

      def epoch_from(datetime)
        (datetime.utc.to_f.round(3) * 1000).to_i
      end
    end
  end
end

require File.join(File.dirname(__FILE__), 'client', 'aws_sdk')
