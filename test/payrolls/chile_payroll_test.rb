require "test_helper"

class ChilePayrollTest < ActiveSupport::TestCase
  fixtures :employees, :health_plans, :assignments
  
  def setup
    @employee = employees(:ana_maria)
    @calculator = ChilePayroll.new(@employee)
  end

  test "returns a PayrollResult object" do
    result = @calculator.calculate
    assert_instance_of Chile::PayrollResult, result
  end

  test "includes employee basic information" do
    result = @calculator.calculate
    
    assert_equal "18.123.456-7", result.employee_rut
    assert_equal "Ana María Rojas", result.employee_name
    assert_equal 1200000, result.base_salary
  end

  test "calculates benefits correctly" do
    result = @calculator.calculate
    
    assert_equal 150000, result.taxable_benefits # Bono Producción
    assert_equal 140000, result.non_taxable_benefits # Movilización + Colación
  end

  test "calculates legal gratification" do
    result = @calculator.calculate
    
    total_taxable = 1200000 + 150000 # base + taxable benefits
    expected_gratification = (total_taxable * 0.25).round
    monthly_limit = ((4.75 * 65000) / 12).round
    
    assert_equal [expected_gratification, monthly_limit].min, result.legal_gratification
  end

  test "calculates AFP correctly" do
    result = @calculator.calculate
    
    total_taxable = result.base_salary + result.taxable_benefits
    gross_taxable = total_taxable + result.legal_gratification
    capped_income = [gross_taxable, 3019200].min # 81.6 UF limit
    
    expected_afp = (capped_income * 0.10).round
    assert_equal expected_afp, result.legal_deductions.afp
  end

  test "calculates health for Fonasa correctly" do
    result = @calculator.calculate
    
    total_taxable = result.base_salary + result.taxable_benefits  
    gross_taxable = total_taxable + result.legal_gratification
    capped_income = [gross_taxable, 3019200].min
    
    expected_health = (capped_income * 0.07).round
    assert_equal expected_health, result.legal_deductions.health
  end

  test "calculates unemployment insurance correctly" do
    result = @calculator.calculate
    
    total_taxable = result.base_salary + result.taxable_benefits
    gross_taxable = total_taxable + result.legal_gratification
    
    expected_unemployment = (gross_taxable * 0.006).round
    assert_equal expected_unemployment, result.legal_deductions.unemployment_insurance
  end

  test "calculates other deductions correctly" do
    result = @calculator.calculate
    
    assert_equal 50000, result.other_deductions # Anticipo Sueldo
  end

  test "calculates net salary correctly" do
    result = @calculator.calculate
    
    total_income = result.base_salary + result.taxable_benefits + 
                  result.non_taxable_benefits + result.legal_gratification
    total_deductions = result.legal_deductions.total + result.other_deductions
    
    expected_net = total_income - total_deductions
    assert_equal expected_net, result.net_salary
  end

  test "uses fixed UF amount for Isapre" do
    isapre_employee = employees(:carlos_soto)
    isapre_calculator = ChilePayroll.new(isapre_employee)
    isapre_result = isapre_calculator.calculate

    expected_health = (4.5 * 37000).round
    assert_equal expected_health, isapre_result.legal_deductions.health
  end

  test "applies income cap for AFP and health" do
    high_salary_employee = employees(:high_earner)
    calculator = ChilePayroll.new(high_salary_employee)
    result = calculator.calculate
    
    # Should be capped at 81.6 UF
    max_capped_income = 81.6 * 37000
    expected_afp = (max_capped_income * 0.10).round
    expected_health = (max_capped_income * 0.07).round
    
    assert_equal expected_afp, result.legal_deductions.afp
    assert_equal expected_health, result.legal_deductions.health
  end
end