require "spec_helper"

RSpec.describe Sqamqp::Connection do
  it "has a default connection params" do
    expect(described_class.connection_params[:host]).to eq '127.0.0.1'
    expect(described_class.connection_params[:port]).to eq 5672
    expect(described_class.connection_params[:user]).to eq 'guest'
    expect(described_class.connection_params[:password]).to eq 'guest'
  end


  it "gets a connection string" do
    expect(described_class::connection_string).to eq "amqp://guest:guest@127.0.0.1:5672"
  end

  it "pulls params from an ENV" do
    ENV["AMQP_USER"] = '1'
    ENV["AMQP_PASSWORD"] = '2'
    ENV["AMQP_HOST"] = '3'
    ENV["AMQP_PORT"] = '4'
    ENV["AMQP_VHOST"] = '5'

    described_class.instance_eval do
      @connection_params=nil
    end

    expect(described_class::connection_string).to eq "amqp://1:2@3:4/5"
  end

  it 'configure' do
    described_class.config do |config|
      config.log_file = 'log/bunny.log'
      config.log_level = Logger::WARN
    end

    expect(described_class.config.log_file).to eq 'log/bunny.log'
    expect(described_class.config.log_level).to eq  Logger::WARN
  end

  context 'establish connection' do
    let(:session) { instance_double("Bunny::Session")}
    let(:bunny) { double("Bunny", start: session) }
    let(:connection_params) { described_class.connection_params }
    let(:config) { described_class.config }

    it 'returns bunny session' do
      expect(Bunny).to receive(:new).with(connection_params, config.options).and_return(bunny)
      expect(described_class.establish_connection).to eq session
    end


    it 'uses connection config' do
      described_class.config do |config|
        config.log_file = 'log/bunny.log'
        config.log_level = Logger::WARN
      end

      expect(Bunny).to receive(:new).with(connection_params, config.options).and_return(bunny)
      described_class.establish_connection
    end

    it 'uses connection config through a block' do
      expect(Bunny).to receive(:new).with(connection_params, config.options).and_return(bunny)
      described_class.establish_connection do |config|
        config.log_file = 'log/bunny.log'
        config.log_level = Logger::WARN
      end

      expect(config.log_file).to eq 'log/bunny.log'
      expect(config.log_level).to eq  Logger::WARN
    end
  end
end
