require "test_helper"

class DisplayTypeTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @type = FactoryBot.create(:display_type)
    @page = FactoryBot.build(:page)
    @page.user = @user
    @page.save!

    5.times do
      display = FactoryBot.build(:display, display_type: @type)
      display.page = @page
      display.display_type = @type
      display.save!
    end
  end

  test "destroying a display type destroys its dependent displays" do
    # assert that there are displays beforehand, or this test is pointless
    assert !Display.where("display_type_id = ?", @type.id).empty?
    @type.destroy
    assert Display.where("display_type_id = ?", @type.id).empty?
  end

  test "display returns empty list if no categories" do
    displays = Display.includes(:page).where(pages: { user_id: @user.id })
    displays.each do |display|
      assert_empty display.categories
      assert_empty display.get_data
    end
  end

  test "display gets data for the correct categories" do
    category1 = FactoryBot.create(:category, user: @user)
    category2 = FactoryBot.create(:category, user: @user)

    display = Display.includes(:page).where(pages: { user_id: @user.id }).first
    display.end_date = DateTime.now + 10.minutes

    # category but no items/entries, returns empty
    display.categories << category1
    assert_empty display.get_data

    # created an item but added to a category that isn't associated with the display - should still return empty
    item = FactoryBot.create(:item, user: @user, categories: [category2])
    entry = FactoryBot.create(:entry, item: item)
    assert_empty display.get_data

    # now create an item and add it to the category associated with the display
    item2 = FactoryBot.create(:item, user: @user, categories: [category1])
    entry = FactoryBot.create(:entry, item: item2)

    display_data = display.get_data
    assert_not_empty display_data
    assert_equal 1, display_data.size
    assert_equal item2, display_data.first
  end
end
