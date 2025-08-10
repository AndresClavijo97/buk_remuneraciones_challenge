require "test_helper"

class Api::PayrollsCalculateTest < ActionDispatch::IntegrationTest
  fixtures :employees, :health_plans, :assignments
  
  def setup
    @employee1 = employees(:ana_maria)
    @employee2 = employees(:carlos_soto)
  end

  test "calculates payroll for specified employees by RUT" do
    ruts_payload = { ruts: [@employee1.rut, @employee2.rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

    assert_response :ok
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("liquidaciones")
    assert_instance_of Array, json_response["liquidaciones"]
    assert_equal 2, json_response["liquidaciones"].size
  end

  test "includes all required payroll fields" do
    ruts_payload = { ruts: [@employee1.rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

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
    ruts_payload = { ruts: [@employee1.rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

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
    ruts_payload = { ruts: [@employee2.rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

    json_response = JSON.parse(response.body)
    carlos_liquidacion = json_response["liquidaciones"].find { |l| l["employee_rut"] == "19.876.543-2" }

    # Isapre with 4.5 UF should use fixed amount instead of 7%
    expected_health = (4.5 * 37000).round # 4.5 UF * UF_VALUE
    assert_equal expected_health, carlos_liquidacion["legal_deductions"]["health"]
  end

  test "calculates legal gratification with limit" do
    ruts_payload = { ruts: [@employee1.rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

    json_response = JSON.parse(response.body)
    liquidacion = json_response["liquidaciones"].first

    total_taxable = liquidacion["base_salary"].to_i + liquidacion["taxable_benefits"].to_i
    calculated_gratification = (total_taxable * 0.25).round
    monthly_limit = ((4.75 * 65000) / 12).round

    expected_gratification = [calculated_gratification, monthly_limit].min
    assert_equal expected_gratification, liquidacion["legal_gratification"]
  end

  test "returns empty array when no matching employees exist" do
    ruts_payload = { ruts: ["99.999.999-9"] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal [], json_response["liquidaciones"]
  end

  test "returns error when ruts parameter is missing" do
    post "/api/payrolls/calculate", as: :json

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert json_response.key?("error")
  end
end