require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @one = FactoryGirl.create(:user)
  end
  
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
  
  test "destroying user destroys associations" do
    user = @one
    user.categories << FactoryGirl.create(:category)
    item = FactoryGirl.create(:item)
    user.items << item
    item.entries << FactoryGirl.create(:entry)
    
    assert !user.categories.empty?
    assert !user.items.empty?
    assert !user.entries.empty?
    assert user.items.include?(item)
    
    item_count = user.items.size
    
    assert_difference('Item.count', (-1 * item_count)) do
        user.destroy
    end
    assert_nil Item.find_by_name(item.name)
  end
  
  test "usernames and email addresses must be unique" do
    user = User.create
    user.username = @one.username
    user.email = @one.email
    user.password = 'password'
    user.password_confirmation = 'password'
    
    assert user.invalid?
    assert user.errors[:username].include?("has already been taken")
    assert user.errors[:email].include?("has already been taken")
    
    user.email = "new" + user.email
    user.username = "new" + user.username
    assert user.valid?
    
  end
end
