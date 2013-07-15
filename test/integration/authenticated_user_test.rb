require 'test_helper'

class AuthenticatedUserTestTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @user_one = users(:one)
    sign_in @user_one
  end
end
