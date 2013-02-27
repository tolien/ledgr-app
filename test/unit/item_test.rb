require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "item must be unique within all its categories" do
      water = items(:water)
      new_water = Item.create(name: water.name, category_ids: water.category_ids)
      
      assert new_water.invalid?
      assert new_water.errors[:name].include?('must be unique in the category')
  end
end
