module Reports
  class CurrentMonthPayroll
    def initialize(ruts, country: 'Chile')
      @ruts = ruts
      @country = country
    end

    def self.calculate(...)
      new(...).calculate
    end
    
    def calculate
      Employee.where(rut: @ruts).map do |employee|
        strategy_for(@country).new(employee).calculate.to_h
      end
    end

    private

    def strategy_for(country)
      "#{country}Payroll".constantize
    end
  end
end