require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user attributes need to be populated" do
    user = User.new
    assert user.invalid?
    
    assert user.errors[:username].any?
    assert user.errors[:email].any?
    assert user.errors[:password].any?
    assert user.errors[:password_confirmation].any?
  end
  
  test "user must have a matching password confirmation" do
    user = User.new
    assert user.invalid?
    
    user.password = 'password'
    
    assert user.errors[:password_confirmation].any?
    user.password_confirmation = 'password12'
    
    assert user.errors[:password_confirmation].any?
    user.password_confirmation = 'password'
  end
end
