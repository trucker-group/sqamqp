require 'bunny'
require 'connection_pool'

module Sqamqp
  module Connection
    @@current_connection = nil
    @@channel_pool = nil
    @@config ||= Sqamqp::Config.new

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
        yield(config) if block_given?
        Bunny.new(connection_params, config.options).start
       end
      @@current_connection
    end

    def self.connection_string
      string = "amqp://#{connection_params[:user]}:#{connection_params[:password]}@#{connection_params[:host]}:#{connection_params[:port]}"
      string << "/" + connection_params[:vhost] if connection_params[:vhost] && connection_params[:vhost] != '/'
      string
    end

    def self.current_connection
      establish_connection(@@current_connection)
    end

    def self.channel_pool
      @@channel_pool ||= ConnectionPool.new(size: connection_params[:pool]) do
        current_connection.create_channel
      end
    end

    def self.config
      yield(@@config) if block_given?
      @@config
    end
  end
end
