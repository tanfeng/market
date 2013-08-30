require 'test_helper'

class WeixinValidateControllerTest < ActionController::TestCase
  test "should get supermall" do
    get :supermall
    assert_response :success
  end

end
