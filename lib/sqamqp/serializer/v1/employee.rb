require 'JSON'

module Sqamqp
  module Serializer
    module V1
      class Employee
        attr_reader :employee

        def initialize(employee)
          @employee = employee
        end

        def attributes
          {
            id: employee.id,
            first_name: employee.first_name,
            last_name: employee.last_name,
            date_in: employee.date_in.to_s,
            date_out: employee.date_out.to_s,
            head_id: employee.head_id,
            department_name: employee.hr_department_name,
            appoint_name: employee.hr_appoint_name,
            # sections: employee.sections
          }
        end

        def to_json
          JSON.generate(attributes)
        end

        def self.parse(body)
          JSON.parse(body, symbolize_names: true)
        end
      end
    end
  end
end
