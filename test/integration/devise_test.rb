require 'test_helper'

class DeviseTest < ActionDispatch::IntegrationTest
  setup do
    @user =  FactoryGirl.build(:user)
    @controller = Devise::RegistrationsController.new
  end
  
  test "can sign up" do
    get new_user_registration_path
    assert_response :success
    assert_difference('User.count') do
      post user_registration_path, user: {username: @user.username, password: @user.password, password_confirmation: @user.password, email: @user.email}
    end
  end

end
