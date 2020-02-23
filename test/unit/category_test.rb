require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @user_one = FactoryBot.create(:user)
    @user_two = FactoryBot.create(:user)
    @drinks = FactoryBot.create(:category)
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

  test "entry count should be zero for a category with no items" do
    hats = FactoryBot.create(:category)
    assert_equal 0, hats.entry_count
  end

  test "entry count should be zero for a category with items wiht no entries" do
    hats = FactoryBot.create(:category, name: "Hats")
    hathat = Item.create(name: "hat", user_id: @user_two.id)
    hathat.add_category hats
    assert_equal 0, hats.entry_count
  end

  test "entry count should be correct" do
    hats = FactoryBot.create(:category, name: "Hats")
    hathat = Item.create(name: "hat", user_id: @user_two.id)
    hathat.add_category hats

    hat_day = Entry.create(quantity: 0, item_id: hathat.id, datetime: DateTime.current)
    hathat.reload
    assert_equal 1, hats.entry_count
  end
end
