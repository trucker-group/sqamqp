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

end
