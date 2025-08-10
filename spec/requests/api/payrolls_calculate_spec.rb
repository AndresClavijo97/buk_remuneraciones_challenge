require 'rails_helper'

RSpec.describe "Api::Payrolls Calculate", type: :request do
  describe "POST /api/payrolls/calculate" do
    let!(:employee1) do
      Employee.create!(
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
    end

    let!(:employee2) do
      Employee.create!(
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

    it "calculates payroll for all employees" do
      post "/api/payrolls/calculate", as: :json

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("liquidaciones")
      expect(json_response["liquidaciones"]).to be_an(Array)
      expect(json_response["liquidaciones"].size).to eq(2)
    end

    it "includes all required payroll fields" do
      post "/api/payrolls/calculate", as: :json

      json_response = JSON.parse(response.body)
      liquidacion = json_response["liquidaciones"].first

      expect(liquidacion).to include(
        "employee_rut",
        "employee_name", 
        "base_salary",
        "taxable_benefits",
        "non_taxable_benefits",
        "legal_gratification",
        "legal_deductions",
        "other_deductions",
        "net_salary"
      )
    end

    it "calculates legal deductions correctly" do
      post "/api/payrolls/calculate", as: :json

      json_response = JSON.parse(response.body)
      ana_liquidacion = json_response["liquidaciones"].find { |l| l["employee_rut"] == "18.123.456-7" }

      expect(ana_liquidacion["legal_deductions"]).to include(
        "afp",
        "health", 
        "unemployment_insurance",
        "income_tax",
        "total"
      )

      # Verify AFP calculation (10% of taxable income)
      total_taxable = ana_liquidacion["base_salary"].to_i + ana_liquidacion["taxable_benefits"].to_i
      gross_taxable = total_taxable + ana_liquidacion["legal_gratification"].to_i
      capped_income = [gross_taxable, 3019200].min # 81.6 UF * 37000

      expected_afp = (capped_income * 0.10).round
      expect(ana_liquidacion["legal_deductions"]["afp"]).to eq(expected_afp)
    end

    it "handles isapre health plan correctly" do
      post "/api/payrolls/calculate", as: :json

      json_response = JSON.parse(response.body)
      carlos_liquidacion = json_response["liquidaciones"].find { |l| l["employee_rut"] == "19.876.543-2" }

      # Isapre with 4.5 UF should use fixed amount instead of 7%
      expected_health = (4.5 * 37000).round # 4.5 UF * UF_VALUE
      expect(carlos_liquidacion["legal_deductions"]["health"]).to eq(expected_health)
    end

    it "calculates legal gratification with limit" do
      post "/api/payrolls/calculate", as: :json

      json_response = JSON.parse(response.body)
      liquidacion = json_response["liquidaciones"].first

      total_taxable = liquidacion["base_salary"].to_i + liquidacion["taxable_benefits"].to_i
      calculated_gratification = (total_taxable * 0.25).round
      monthly_limit = ((4.75 * 65000) / 12).round

      expected_gratification = [calculated_gratification, monthly_limit].min
      expect(liquidacion["legal_gratification"]).to eq(expected_gratification)
    end

    it "returns error when no employees exist" do
      Employee.destroy_all
      
      post "/api/payrolls/calculate", as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["liquidaciones"]).to eq([])
    end
  end
end