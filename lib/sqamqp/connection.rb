require 'bunny'

module Sqamqp
  module Connection
    AMQP_CONNECTION_PARAMS = {
      host: ENV['AMQP_HOST'] || '127.0.0.1',
      port: ENV['AMQP_PORT'] || 5672,
      user:  ENV['AMQP_USER'] || 'guest',
      password: ENV['AMQP_PASSWORD'] || 'guest',
      pool: ENV['AMQP_POOL'] || 10
    }

    def self.establish_connection
      @@current_connection = Bunny.new(AMQP_CONNECTION_PARAMS).tap do |c|
        c.start
      end

      @@channel_pool = ConnectionPool.new(size: AMQP_CONNECTION_PARAMS[:pool]) do
        @@current_connection.create_channel
      end
    end

    def self.connection_string
      "amqp://#{AMQP_CONNECTION_PARAMS[:user]}:#{AMQP_CONNECTION_PARAMS[:password]}@#{AMQP_CONNECTION_PARAMS[:host]}:#{AMQP_CONNECTION_PARAMS[:port]}"
    end

    def self.current_connection
      @@current_connection
    end

    def self.channel_pool
      @@channel_pool
    end
  end
end