class Api::PayrollsController < ApplicationController
  def load

    with_transaction do
      Employee.destroy_all
      Employee.create!(permitted_params)
    end
  
    render json: { message: "Data loaded successfully" }, status: :ok

  rescue => e
    render json: { error: e.message }, status: :bad_request
  end

  def calculate
    render status: :ok
  end

  private

  def permitted_params
    params.require(:data).map do |employee_data|
      employee_data.permit(
        :rut, :name, :hire_date, :base_salary,
        health_plan_attributes: [:plan_type, :plan_uf],
        assignments_attributes: [:name, :assignment_type, :amount, :taxable, :tributable]
      )
    end
  end

  def with_transaction(&)
    ApplicationRecord.transaction(&)
  end
end
