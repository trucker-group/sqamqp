require "spec_helper"

class Employee
  def id; 11; end;
  def first_name; 'Иван'; end;
  def last_name; 'Петров'; end;
  def date_in; Date.new(2017,07,01); end;
  def date_out; nil end;
  def head_id; 33 end;
  def hr_department_name; 'DEV' end;
  def hr_appoint_name; 'Програмист' end;
end

RSpec.describe Sqamqp::Serializer::V1::Employee do
  subject { described_class.new(employee) }
  let(:employee) { Employee.new }

  it "has attributes" do
    res = described_class.parse(subject.to_json)

    subject.attributes.each do |k,v|
      expect(res[k]).to eq v
    end
  end
end
