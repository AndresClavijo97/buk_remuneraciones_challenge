class Api::PayrollsController < ApplicationController
  rescue_from StandardError, with: :handle_error

  def load
    with_transaction do
      Employee.destroy_all
      Employee.create!(permitted_params)
    end
  
    render json: { message: "Data loaded successfully" }, status: :ok
  end

  def calculate
    if params[:ruts].present?
      liquidaciones = Payrolls::CurrentMonthCalculator.calculate(params[:ruts])
      render json: { liquidaciones: liquidaciones }, status: :ok
    else
      render json: { error: "Parameter 'ruts' is required" }, status: :bad_request
    end
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
end
