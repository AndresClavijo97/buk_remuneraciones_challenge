require "test_helper"

class Api::PayrollsCalculateTest < ActionDispatch::IntegrationTest
  def setup
    @employee1 = Employee.create!(
      rut: "18.123.456-7",
      name: "Ana María Rojas",
      hire_date: "2023-01-01",
      base_salary: 1200000,
      health_plan_attributes: { plan_type: "fonasa" },
      assignments_attributes: [
        {
          name: "Movilización",
          assignment_type: "benefit",
          amount: 80000,
          taxable: false,
          tributable: false
        },
        {
          name: "Bono Producción",
          assignment_type: "benefit",
          amount: 150000,
          taxable: true,
          tributable: true
        },
        {
          name: "Anticipo Sueldo",
          assignment_type: "deduction",
          amount: 50000,
          taxable: false,
          tributable: false
        }
      ]
    )

    @employee2 = Employee.create!(
      rut: "19.876.543-2",
      name: "Carlos Soto Pérez",
      hire_date: "2024-07-15",
      base_salary: 950000,
      health_plan_attributes: { plan_type: "isapre", plan_uf: 4.5 },
      assignments_attributes: [
        {
          name: "Comisión Ventas",
          assignment_type: "benefit",
          amount: 75000,
          taxable: true,
          tributable: true
        }
      ]
    )
  end

  test "calculates payroll for all employees" do
    post "/api/payrolls/calculate", as: :json

    assert_response :ok
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("liquidaciones")
    assert_instance_of Array, json_response["liquidaciones"]
    assert_equal 2, json_response["liquidaciones"].size
  end

  test "includes all required payroll fields" do
    post "/api/payrolls/calculate", as: :json

    json_response = JSON.parse(response.body)
    liquidacion = json_response["liquidaciones"].first

    assert liquidacion.key?("employee_rut")
    assert liquidacion.key?("employee_name")
    assert liquidacion.key?("base_salary")
    assert liquidacion.key?("taxable_benefits")
    assert liquidacion.key?("non_taxable_benefits")
    assert liquidacion.key?("legal_gratification")
    assert liquidacion.key?("legal_deductions")
    assert liquidacion.key?("other_deductions")
    assert liquidacion.key?("net_salary")
  end

  test "calculates legal deductions correctly" do
    post "/api/payrolls/calculate", as: :json

    json_response = JSON.parse(response.body)
    ana_liquidacion = json_response["liquidaciones"].find { |l| l["employee_rut"] == "18.123.456-7" }

    assert ana_liquidacion["legal_deductions"].key?("afp")
    assert ana_liquidacion["legal_deductions"].key?("health")
    assert ana_liquidacion["legal_deductions"].key?("unemployment_insurance")
    assert ana_liquidacion["legal_deductions"].key?("income_tax")
    assert ana_liquidacion["legal_deductions"].key?("total")

    # Verify AFP calculation (10% of taxable income)
    total_taxable = ana_liquidacion["base_salary"].to_i + ana_liquidacion["taxable_benefits"].to_i
    gross_taxable = total_taxable + ana_liquidacion["legal_gratification"].to_i
    capped_income = [gross_taxable, 3019200].min # 81.6 UF * 37000

    expected_afp = (capped_income * 0.10).round
    assert_equal expected_afp, ana_liquidacion["legal_deductions"]["afp"]
  end

  test "handles isapre health plan correctly" do
    post "/api/payrolls/calculate", as: :json

    json_response = JSON.parse(response.body)
    carlos_liquidacion = json_response["liquidaciones"].find { |l| l["employee_rut"] == "19.876.543-2" }

    # Isapre with 4.5 UF should use fixed amount instead of 7%
    expected_health = (4.5 * 37000).round # 4.5 UF * UF_VALUE
    assert_equal expected_health, carlos_liquidacion["legal_deductions"]["health"]
  end

  test "calculates legal gratification with limit" do
    post "/api/payrolls/calculate", as: :json

    json_response = JSON.parse(response.body)
    liquidacion = json_response["liquidaciones"].first

    total_taxable = liquidacion["base_salary"].to_i + liquidacion["taxable_benefits"].to_i
    calculated_gratification = (total_taxable * 0.25).round
    monthly_limit = ((4.75 * 65000) / 12).round

    expected_gratification = [calculated_gratification, monthly_limit].min
    assert_equal expected_gratification, liquidacion["legal_gratification"]
  end

  test "returns empty array when no employees exist" do
    Employee.destroy_all
    
    post "/api/payrolls/calculate", as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal [], json_response["liquidaciones"]
  end
end