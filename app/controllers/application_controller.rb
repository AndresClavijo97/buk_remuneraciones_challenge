class ApplicationController < ActionController::API
  def with_transaction(&)
    ApplicationRecord.transaction(&)
  end

  def handle_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
