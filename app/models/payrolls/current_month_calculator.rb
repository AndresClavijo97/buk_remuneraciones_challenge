module Payrolls
  class CurrentMonthCalculator
    def self.calculate(ruts)
      Employee.where(rut: ruts).map { |employee| Payrolls::Calculator.new(employee).calculate.to_h }
    end
  end
end