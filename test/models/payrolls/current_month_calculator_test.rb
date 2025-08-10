require "test_helper"

class Payrolls::CurrentMonthCalculatorTest < ActiveSupport::TestCase
  fixtures :employees, :health_plans, :assignments
  
  def setup
    @employee1 = employees(:ana_maria)
    @employee2 = employees(:carlos_soto)
  end

  test "calculates payroll for all employees" do
    results = Payrolls::CurrentMonthCalculator.calculate
    
    assert_instance_of Array, results
    assert_equal 3, results.size
  end

  test "returns hash format for each employee" do
    results = Payrolls::CurrentMonthCalculator.calculate
    result = results.first
    
    assert_instance_of Hash, result
    assert result.key?(:employee_rut)
    assert result.key?(:employee_name)
    assert result.key?(:base_salary)
    assert result.key?(:net_salary)
  end

  test "includes correct employee data" do
    results = Payrolls::CurrentMonthCalculator.calculate
    ana_result = results.find { |r| r[:employee_rut] == "18.123.456-7" }
    carlos_result = results.find { |r| r[:employee_rut] == "19.876.543-2" }

    assert_equal "Ana María Rojas", ana_result[:employee_name]
    assert_equal 1200000, ana_result[:base_salary]
    
    assert_equal "Carlos Soto Pérez", carlos_result[:employee_name]
    assert_equal 950000, carlos_result[:base_salary]
  end

  test "returns empty array with no employees" do
    Employee.destroy_all
    results = Payrolls::CurrentMonthCalculator.calculate
    
    assert_equal [], results
  end
end