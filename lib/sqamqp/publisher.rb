module Sqamqp
  module Publisher
    def publish
      Sqamqp::Connection.establish_connection(Sqamqp::Connection.current_connection)

      channel_pool.with do |channel|
        configure_channel(channel).publish(payload.to_json, persistent: true, routing_key: event)
      end
    end

    def channel_pool
      @channel_pool ||= Sqamqp::Connection.channel_pool
    end
  end
end