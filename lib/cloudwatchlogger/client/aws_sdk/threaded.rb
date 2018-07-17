require 'aws-sdk-cloudwatchlogs'

module CloudWatchLogger
  module Client
    class AwsSDK
      # Used by the Threaded client to manage the delivery thread
      # recreating it if is lost due to a fork.
      #
      class DeliveryThreadManager
        def initialize(credentials, log_group_name, log_stream_name, opts = {})
          @credentials = credentials
          @log_group_name = log_group_name
          @log_stream_name = log_stream_name
          @opts = opts
          start_thread
        end

        # Pushes a message to the delivery thread, starting one if necessary
        def deliver(message)
          start_thread unless @thread.alive?
          @thread.deliver(message)
          # Race condition? Sometimes we need to rescue this and start a new thread
        rescue NoMethodError
          @thread.kill # Try not to leak threads, should already be dead anyway
          start_thread
          retry
        end

        private

        def start_thread
          @thread = DeliveryThread.new(@credentials, @log_group_name, @log_stream_name, @opts)
        end
      end

      class DeliveryThread < Thread
        def initialize(credentials, log_group_name, log_stream_name, opts = {})
          opts[:open_timeout] = opts[:open_timeout] || 120
          opts[:read_timeout] = opts[:read_timeout] || 120
          @credentials = credentials
          @log_group_name = log_group_name
          @log_stream_name = log_stream_name
          @opts = opts

          @queue = Queue.new
          @exiting = false

          super do
            loop do
              setup_resources! if @client.nil?

              msg = @queue.pop
              break if msg == :__delivery_thread_exit_signal__

              begin
                event = {
                  log_group_name: @log_group_name,
                  log_stream_name: @log_stream_name,
                  log_events: [{
                    timestamp: (Time.now.utc.to_f.round(3) * 1000).to_i,
                    message: msg
                  }]
                }
                event[:sequence_token] = @sequence_token if @sequence_token
                response = client.put_log_events(event)
                unless response.rejected_log_events_info.nil?
                  raise CloudWatchLogger::LogEventRejected
                end
                @sequence_token = response.next_sequence_token
              rescue Aws::CloudWatchLogs::Errors::InvalidSequenceTokenException => err
                @sequence_token = err.message.split(' ').last
                retry
              end
            end
          end

          at_exit do
            exit!
            join
          end
        end

        # Signals the queue that we're exiting
        def exit!
          @exiting = true
          @queue.push :__delivery_thread_exit_signal__
        end

        # Pushes a message onto the internal queue
        def deliver(message)
          @queue.push(message)
        end

        def setup_resources!
          create_log_stream
        rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
          create_log_group
          retry
        rescue Aws::CloudWatchLogs::Errors::ResourceAlreadyExistsException
          handle_exception
        end

        def handle_exception; end

        def client
          @client ||= Aws::CloudWatchLogs::Client.new(
            region: @opts[:region] || 'us-east-1',
            access_key_id: @credentials[:access_key_id],
            secret_access_key: @credentials[:secret_access_key],
            http_open_timeout: @opts[:open_timeout],
            http_read_timeout: @opts[:read_timeout]
          )
        end

        def create_log_stream
          client.create_log_stream(
            log_group_name: @log_group_name,
            log_stream_name: @log_stream_name
          )
        end

        def create_log_group
          client.create_log_group(
            log_group_name: @log_group_name
          )
        end
      end
    end
  end
end
