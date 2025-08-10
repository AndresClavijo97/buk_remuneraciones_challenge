module Payrolls
  class CurrentMonthCalculator
    def self.calculate
      Employee.all.map { |employee| Payrolls::Calculator.new(employee).calculate.to_h }
    end
  end
end