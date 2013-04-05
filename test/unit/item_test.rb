require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  setup do
    @drinks = categories(:drinks)
    @water = items(:water)
    @water.categories << @drinks
  end
  
  test "item with no categories is valid" do
    item = Item.create(name: 'test item')
    assert item.valid?
  end
  
  test "item must be unique within all its categories" do
      # item in one category
      new_water = Item.create(name: @water.name)
      new_water.add_category(@drinks)
      
      assert new_water.invalid?
#      assert new_water.errors[:name].include?('must be unique in the category'), "The item should have an error"
      
      # item in two categories
      hats = categories(:hats)
      water_hat = Item.create(name: "Water")
      water_hat.add_category(hats)
#      assert water_hat.valid?
      water_hat.add_category(@drinks)
      assert water_hat.invalid?
      
  end
  
  test "an item may only be a member of a category once" do
    assert @water.categories.include?(@drinks), "water is already a member of drinks"
    water = @water
    #assert_raise ActiveRecord::RecordInvalid, water.categories << @drinks, "Trying to add another item with the same name should raise an exception"
  end
  
end
