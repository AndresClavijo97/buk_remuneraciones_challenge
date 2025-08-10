require 'rails_helper'

RSpec.describe Payrolls::Calculator, type: :model do
  let(:employee) do
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

  let(:calculator) { described_class.new(employee) }
  let(:result) { calculator.calculate }

  describe "#calculate" do
    it "returns a PayrollResult object" do
      expect(result).to be_a(PayrollResult)
    end

    it "includes employee basic information" do
      expect(result.employee_rut).to eq("18.123.456-7")
      expect(result.employee_name).to eq("Ana María Rojas")
      expect(result.base_salary).to eq(1200000)
    end

    it "calculates benefits correctly" do
      expect(result.taxable_benefits).to eq(150000) # Bono Producción
      expect(result.non_taxable_benefits).to eq(80000) # Movilización
    end

    it "calculates legal gratification" do
      total_taxable = 1200000 + 150000 # base + taxable benefits
      expected_gratification = (total_taxable * 0.25).round
      monthly_limit = ((4.75 * 65000) / 12).round
      
      expect(result.legal_gratification).to eq([expected_gratification, monthly_limit].min)
    end

    it "calculates AFP correctly" do
      total_taxable = result.base_salary + result.taxable_benefits
      gross_taxable = total_taxable + result.legal_gratification
      capped_income = [gross_taxable, 3019200].min # 81.6 UF limit
      
      expected_afp = (capped_income * 0.10).round
      expect(result.legal_deductions.afp).to eq(expected_afp)
    end

    it "calculates health for Fonasa correctly" do
      total_taxable = result.base_salary + result.taxable_benefits  
      gross_taxable = total_taxable + result.legal_gratification
      capped_income = [gross_taxable, 3019200].min
      
      expected_health = (capped_income * 0.07).round
      expect(result.legal_deductions.health).to eq(expected_health)
    end

    it "calculates unemployment insurance correctly" do
      total_taxable = result.base_salary + result.taxable_benefits
      gross_taxable = total_taxable + result.legal_gratification
      
      expected_unemployment = (gross_taxable * 0.006).round
      expect(result.legal_deductions.unemployment_insurance).to eq(expected_unemployment)
    end

    it "calculates other deductions correctly" do
      expect(result.other_deductions).to eq(50000) # Anticipo Sueldo
    end

    it "calculates net salary correctly" do
      total_income = result.base_salary + result.taxable_benefits + 
                    result.non_taxable_benefits + result.legal_gratification
      total_deductions = result.legal_deductions.total + result.other_deductions
      
      expected_net = total_income - total_deductions
      expect(result.net_salary).to eq(expected_net)
    end
  end

  describe "with Isapre employee" do
    let(:isapre_employee) do
      Employee.create!(
        rut: "19.876.543-2",
        name: "Carlos Soto",
        hire_date: "2024-01-01", 
        base_salary: 1500000,
        health_plan_attributes: { plan_type: "isapre", plan_uf: 5.2 }
      )
    end

    let(:isapre_calculator) { described_class.new(isapre_employee) }
    let(:isapre_result) { isapre_calculator.calculate }

    it "uses fixed UF amount for Isapre" do
      expected_health = (5.2 * 37000).round
      expect(isapre_result.legal_deductions.health).to eq(expected_health)
    end
  end

  describe "edge cases" do
    let(:high_salary_employee) do
      Employee.create!(
        rut: "20.111.222-3",
        name: "High Earner",
        hire_date: "2023-01-01",
        base_salary: 5000000,
        health_plan_attributes: { plan_type: "fonasa" }
      )
    end

    it "applies income cap for AFP and health" do
      calculator = described_class.new(high_salary_employee)
      result = calculator.calculate
      
      # Should be capped at 81.6 UF
      max_capped_income = 81.6 * 37000
      expected_afp = (max_capped_income * 0.10).round
      expected_health = (max_capped_income * 0.07).round
      
      expect(result.legal_deductions.afp).to eq(expected_afp)
      expect(result.legal_deductions.health).to eq(expected_health)
    end
  end
end