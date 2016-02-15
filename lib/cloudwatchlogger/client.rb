require 'multi_json'
require 'socket'
require 'thread'
require 'uuid'

module CloudWatchLogger
  module Client

    def self.new(credentials, log_group_name, log_stream_name=nil, opts={})
      unless log_group_name
        raise LogGroupNameRequired.new
      end

      CloudWatchLogger::Client::AWS_SDK.new(credentials, log_group_name, log_stream_name, opts)
    end

    module InstanceMethods

      def masherize_key(prefix,key)
        [prefix,key.to_s].compact.join('.')
      end

      def masher(hash, prefix=nil)
        hash.map do |v|
          if v[1].is_a?(Hash)
            masher(v[1],masherize_key(prefix,v[0]))
          else
            "#{masherize_key(prefix,v[0])}=" << case v[1]
            when Symbol
              v[1].to_s
            else
              v[1].inspect
            end
          end
        end.join(", ")
      end

      def formatter
        proc do |severity, datetime, progname, msg|
          processid=Process.pid
          if @format == :json && msg.is_a?(Hash)
            MultiJson.dump(msg.merge({ :severity => severity,
                                       :datetime => datetime,
                                       :progname => progname,
                                       :pid      => processid }))
          else
            message = "#{datetime} "
            message << massage_message(msg, severity, processid)
          end
        end
      end

      def massage_message(incoming_message, severity, processid)
        outgoing_message = ""
        
        outgoing_message << "pid=#{processid}, thread=#{Thread.current.object_id}, severity=#{severity}, "
        
        case incoming_message
        when Hash
          outgoing_message << masher(incoming_message)
        when String
          outgoing_message << incoming_message
        else
          outgoing_message << incoming_message.inspect
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
        @log_stream_name = name
        if @log_stream_name.nil?
          uuid = UUID.new
          @log_stream_name = "#{Socket.gethostname}-#{uuid.generate}"
        end
      end

    end

  end
end

require File.join(File.dirname(__FILE__), 'client', 'aws_sdk')