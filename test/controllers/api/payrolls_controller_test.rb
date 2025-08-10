require "test_helper"

class Api::PayrollsControllerTest < ActionDispatch::IntegrationTest
  fixtures :employees, :health_plans, :assignments

  test "should get calculate with ruts parameter" do
    ruts_payload = { ruts: [employees(:ana_maria).rut] }
    post "/api/payrolls/calculate", params: ruts_payload, as: :json
    assert_response :success
  end
end
