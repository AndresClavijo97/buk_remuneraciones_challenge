require "test_helper"

class Api::PayrollsTest < ActionDispatch::IntegrationTest
  def setup
    @payload = JSON.parse(file_fixture("payroll_data.json").read)
  end

  test "successfully loads all employee data when data is valid" do
    put "/api/payrolls/load", params: @payload, as: :json

    assert_response :ok
    assert_equal({ "message" => "Data loaded successfully" }, JSON.parse(response.body))
    assert_equal 2, Employee.count
  end

  test "creates employees with correct attributes" do
    put "/api/payrolls/load", params: @payload, as: :json

    ana = Employee.find_by(rut: "18.123.456-7")
    assert_equal "Ana María Rojas", ana.name
    assert_equal Date.parse("2023-01-01"), ana.hire_date
    assert_equal 1200000, ana.base_salary
  end

  test "creates health plans correctly" do
    put "/api/payrolls/load", params: @payload, as: :json

    ana = Employee.find_by(rut: "18.123.456-7")
    assert_equal "fonasa", ana.health_plan.plan_type
    assert_nil ana.health_plan.plan_uf

    carlos = Employee.find_by(rut: "19.876.543-2")
    assert_equal "isapre", carlos.health_plan.plan_type
    assert_equal 4.5, carlos.health_plan.plan_uf
  end

  test "creates assignments correctly" do
    put "/api/payrolls/load", params: @payload, as: :json

    ana = Employee.find_by(rut: "18.123.456-7")
    assert_equal 4, ana.assignments.count

    movilizacion = ana.assignments.find_by(name: "Movilización")
    assert_equal "benefit", movilizacion.assignment_type
    assert_equal 80000, movilizacion.amount
    assert_not movilizacion.taxable
    assert_not movilizacion.tributable

    bono = ana.assignments.find_by(name: "Bono Producción")
    assert_equal "benefit", bono.assignment_type
    assert_equal 150000, bono.amount
    assert bono.taxable
    assert bono.tributable

    anticipo = ana.assignments.find_by(name: "Anticipo Sueldo")
    assert_equal "deduction", anticipo.assignment_type
    assert_equal 50000, anticipo.amount
  end

  test "returns error for invalid employee data" do
    initial_count = Employee.count
    invalid_payload = JSON.parse(file_fixture("invalid_payroll_data.json").read)

    put "/api/payrolls/load", params: invalid_payload, as: :json

    assert_response :bad_request
    assert JSON.parse(response.body).key?("error")
    assert_equal initial_count, Employee.count
  end
end