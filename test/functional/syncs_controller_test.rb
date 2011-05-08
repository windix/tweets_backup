require 'test_helper'

class SyncsControllerTest < ActionController::TestCase
  test "should get setup" do
    get :setup
    assert_response :success
  end

end
