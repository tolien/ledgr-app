require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @drinks = categories(:drinks)
  end
  
  test "category validation" do
    category = Category.create

    assert category.invalid?    
    assert category.errors[:name].include? "can't be blank"
    assert category.errors[:user].include? "can't be blank"
    
    category.user_id = @user_two.id
    category.name = "wibble"
    assert category.valid?
  end
  
  test "categories should be unique per-user" do
    drinks = Category.create(name: @drinks.name, user_id: @drinks.user_id)
    assert drinks.invalid?
    assert drinks.errors[:name].include?("has already been taken")
    
    drinks.user_id = @user_two.id
    assert drinks.valid?
  end
end
