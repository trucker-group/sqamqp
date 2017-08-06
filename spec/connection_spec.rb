require "spec_helper"

RSpec.describe Sqamqp::Connection do
  it "has a default connection params" do
    expect(described_class::AMQP_CONNECTION_PARAMS[:host]).to eq '127.0.0.1'
    expect(described_class::AMQP_CONNECTION_PARAMS[:port]).to eq 5672
    expect(described_class::AMQP_CONNECTION_PARAMS[:user]).to eq 'guest'
    expect(described_class::AMQP_CONNECTION_PARAMS[:password]).to eq 'guest'
  end


  it "gets a connection string" do
    expect(described_class::connection_string).to eq "amqp://guest:guest@127.0.0.1:5672"
  end

end
