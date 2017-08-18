require 'bunny'
require 'dotenv/load'

module Sqamqp
  module Connection
    def self.connection_params
      @connection_params ||= {
        host: ENV['AMQP_HOST'] || '127.0.0.1',
        port: ENV['AMQP_PORT'] || 5672,
        user:  ENV['AMQP_USER'] || 'guest',
        password: ENV['AMQP_PASSWORD'] || 'guest',
        vhost: ENV['AMQP_VHOST'] || '/',
        pool: ENV['AMQP_POOL'] || 10
      }
    end

    def self.establish_connection(connection = nil)
      @@current_connection = if connection
        connection
      else
        config = Sqamqp::Config.new
        yield(config)
        Bunny.new(connection_params, config.options).start
       end

      @@channel_pool = ConnectionPool.new(size: connection_params[:pool]) do
        @@current_connection.create_channel
      end

      @@current_connection
    end

    def self.connection_string
      string = "amqp://#{connection_params[:user]}:#{connection_params[:password]}@#{connection_params[:host]}:#{connection_params[:port]}"
      string << "/" + connection_params[:vhost] if connection_params[:vhost] && connection_params[:vhost] != '/'
      string
    end

    def self.current_connection
      @@current_connection
    end

    def self.channel_pool
      @@channel_pool
    end
  end
end
