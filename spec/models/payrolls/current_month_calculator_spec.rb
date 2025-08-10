require 'rails_helper'

RSpec.describe Payrolls::CurrentMonthCalculator, type: :model do
  describe ".calculate" do
    context "with employees in database" do
      let!(:employee1) do
        Employee.create!(
          rut: "18.123.456-7",
          name: "Ana María Rojas",
          hire_date: "2023-01-01", 
          base_salary: 1200000,
          health_plan_attributes: { plan_type: "fonasa" }
        )
      end

      let!(:employee2) do
        Employee.create!(
          rut: "19.876.543-2", 
          name: "Carlos Soto",
          hire_date: "2024-01-01",
          base_salary: 950000,
          health_plan_attributes: { plan_type: "isapre", plan_uf: 4.5 }
        )
      end

      it "calculates payroll for all employees" do
        results = described_class.calculate
        
        expect(results).to be_an(Array)
        expect(results.size).to eq(2)
      end

      it "returns hash format for each employee" do
        results = described_class.calculate
        result = results.first
        
        expect(result).to be_a(Hash)
        expect(result).to have_key(:employee_rut)
        expect(result).to have_key(:employee_name)
        expect(result).to have_key(:base_salary)
        expect(result).to have_key(:net_salary)
      end

      it "includes correct employee data" do
        results = described_class.calculate
        ana_result = results.find { |r| r[:employee_rut] == "18.123.456-7" }
        carlos_result = results.find { |r| r[:employee_rut] == "19.876.543-2" }

        expect(ana_result[:employee_name]).to eq("Ana María Rojas")
        expect(ana_result[:base_salary]).to eq(1200000)
        
        expect(carlos_result[:employee_name]).to eq("Carlos Soto")
        expect(carlos_result[:base_salary]).to eq(950000)
      end
    end

    context "with no employees" do
      it "returns empty array" do
        Employee.destroy_all
        results = described_class.calculate
        
        expect(results).to eq([])
      end
    end
  end
end