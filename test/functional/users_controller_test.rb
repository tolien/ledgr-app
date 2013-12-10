require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end
  
  test "should show user" do
    get :show, id: @user.id
    assert_response :success
    assert_template :show
  end
end
