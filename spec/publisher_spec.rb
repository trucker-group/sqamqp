require "spec_helper"

RSpec.describe Sqamqp::Publisher do

  class MockChannel
    def publish(json, persistent: true, routing_key: nil)
    end
  end

  class MockPublisher
    require 'json'
    include Sqamqp::Publisher

    def configure_channel(channel)
      MockChannel.new
    end

    def event
      'create'
    end

    def payload
      { message: 'message' }
    end
  end

  context "on publish" do
    before do
     Sqamqp::Connection.class_variable_set(:@@current_connection, nil)
    end

    let(:session) { double("Bunny::Session", create_channel: true) }
    let(:bunny) { double("Bunny", start: session) }

    it 'creates a new connection if it was not created before' do
      expect(Bunny).to receive(:new).and_return(bunny)
      expect { MockPublisher.new.publish }.to change { Sqamqp::Connection.current_connection }.from(nil).to(session)
    end

    it 'uses the connection created before' do
      expect(Bunny).to receive(:new).and_return(bunny)
      expect(Sqamqp::Connection.establish_connection).to eq(session)
      expect { MockPublisher.new.publish }.to_not change { Sqamqp::Connection.current_connection }
    end
  end
end