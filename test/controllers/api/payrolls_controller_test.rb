require "test_helper"

class Api::PayrollsControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    post "/api/payrolls/calculate"
    assert_response :success
  end
end
