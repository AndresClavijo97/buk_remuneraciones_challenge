class CurrentMonthCalculator
  def self.calculate(ruts)
    Employee.where(rut: ruts).map { |employee| ChilePayroll.new(employee).calculate.to_h }
  end
end