require "test_helper"

class DisplayTest < ActiveSupport::TestCase
  setup do
    @display_type = FactoryBot.build(:display_type)
    @page = FactoryBot.build(:owned_page)
  end

  test "a Display must be associated with a display type and page" do
    display = Display.create
    assert display.invalid?

    assert display.errors[:display_type].include? "can't be blank"
    assert display.errors[:page].include? "can't be blank"

    display.display_type = @display_type
    display.page = @page

    assert display.valid?
  end

  test "displays are loaded in the correct order" do
    display_list = []

    @page.save!
    assert_not_nil @page
    assert_not_nil @page.id

    @display_type.save
    display = FactoryBot.build(:display, page: @page, display_type: @display_type)
    assert display.valid?

    10.times do
      display = display.dup
      display.position = nil

      display.save!
      display_list.append(display.id)
    end

    moved = @page.displays.first
    moved.move_to_bottom
    display_list.append(display_list.shift)

    assert_equal 10, @page.displays.count
    @page.displays.reload.each do |display|
      id = display_list.shift
      assert_not_nil id
      assert_equal id, display.id
    end
  end

  test "get_item_list works as expected" do
    display = FactoryBot.create(:display, page: @page, end_date: nil)

    assert_nil display.get_item_list

    category = FactoryBot.create(:category)
    item = FactoryBot.create(:item)
    entry = FactoryBot.create(:entry, item: item)
    item.categories << category

    display.categories << category
    assert_not_nil display.get_item_list
    assert_equal 1, display.get_item_list.size
    assert_equal item.name, display.get_item_list.first.name
  end
end
