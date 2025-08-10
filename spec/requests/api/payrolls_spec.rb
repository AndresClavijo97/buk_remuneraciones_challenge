require 'rails_helper'

RSpec.describe "Api::Payrolls", type: :request do
  describe "PUT /api/payrolls/load" do
    let(:payload) do
      {
        "data": [
          {
            "rut": "18.123.456-7",
            "name": "Ana María Rojas",
            "hire_date": "2023-01-01",
            "base_salary": 1200000,
            "health_plan_attributes": {
              "plan_type": "fonasa"
            },
            "assignments_attributes": [
              {
                "name": "Movilización",
                "assignment_type": "benefit",
                "amount": 80000,
                "taxable": false,
                "tributable": false
              },
              {
                "name": "Colación",
                "assignment_type": "benefit",
                "amount": 60000,
                "taxable": false,
                "tributable": false
              },
              {
                "name": "Bono Producción",
                "assignment_type": "benefit",
                "amount": 150000,
                "taxable": true,
                "tributable": true
              },
              {
                "name": "Anticipo Sueldo",
                "assignment_type": "deduction",
                "amount": 50000,
                "taxable": false,
                "tributable": false
              }
            ]
          },
          {
            "rut": "19.876.543-2",
            "name": "Carlos Soto Pérez",
            "hire_date": "2024-07-15",
            "base_salary": 950000,
            "health_plan_attributes": {
              "plan_type": "isapre",
              "plan_uf": 4.5
            },
            "assignments_attributes": [
              {
                "name": "Movilización Proporcional",
                "assignment_type": "benefit",
                "amount": 40000,
                "taxable": false,
                "tributable": false
              }
            ]
          }
        ]
      }
    end

    context "when data is valid" do
      it "successfully loads all employee data" do
        expect {
          put "/api/payrolls/load", params: payload, as: :json
        }.to change(Employee, :count).from(0).to(2)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "message" => "Data loaded successfully" })
      end

      it "creates employees with correct attributes" do
        put "/api/payrolls/load", params: payload, as: :json

        ana = Employee.find_by(rut: "18.123.456-7")
        expect(ana.name).to eq("Ana María Rojas")
        expect(ana.hire_date).to eq(Date.parse("2023-01-01"))
        expect(ana.base_salary).to eq(1200000)
      end

      it "creates health plans correctly" do
        put "/api/payrolls/load", params: payload, as: :json

        ana = Employee.find_by(rut: "18.123.456-7")
        expect(ana.health_plan.plan_type).to eq("fonasa")
        expect(ana.health_plan.plan_uf).to be_nil

        carlos = Employee.find_by(rut: "19.876.543-2")
        expect(carlos.health_plan.plan_type).to eq("isapre")
        expect(carlos.health_plan.plan_uf).to eq(4.5)
      end

      it "creates assignments correctly" do
        put "/api/payrolls/load", params: payload, as: :json

        ana = Employee.find_by(rut: "18.123.456-7")
        expect(ana.assignments.count).to eq(4)

        movilizacion = ana.assignments.find_by(name: "Movilización")
        expect(movilizacion.assignment_type).to eq("benefit")
        expect(movilizacion.amount).to eq(80000)
        expect(movilizacion.taxable).to be_falsey
        expect(movilizacion.tributable).to be_falsey

        bono = ana.assignments.find_by(name: "Bono Producción")
        expect(bono.assignment_type).to eq("benefit")
        expect(bono.amount).to eq(150000)
        expect(bono.taxable).to be_truthy
        expect(bono.tributable).to be_truthy

        anticipo = ana.assignments.find_by(name: "Anticipo Sueldo")
        expect(anticipo.assignment_type).to eq("deduction")
        expect(anticipo.amount).to eq(50000)
      end
    end

    context "when data is invalid" do
      it "returns error for invalid employee data" do
        invalid_payload = {
          data: [
            {
              rut: "",
              name: "Invalid Employee",
              hire_date: "2023-01-01",
              base_salary: -1000
            }
          ]
        }

        put "/api/payrolls/load", params: invalid_payload, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to have_key("error")
        expect(Employee.count).to eq(0)
      end
    end
  end
end