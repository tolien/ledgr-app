require "test_helper"
require "action_view"
include ActionView::Helpers::DateHelper

class PageTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
  end

  test "a page must be owned by a user" do
    page = FactoryBot.build(:page)
    assert page.invalid?
    assert page.errors[:user].include?("can't be blank")
  end

  test "page position must be an integer" do
    page = FactoryBot.build(:owned_page)

    page.position = "I'm a little teapot"
    assert_not page.valid?
    assert_not page.errors[:position].empty?

    # this is a strange one - before validation, acts_as_list resets the position
    # to list top: 1, by default
    page.position = -1
    assert page.valid?
    assert_equal 1, page.position
    assert page.errors[:position].empty?

    page.position = 0
    page.valid?
    assert page.valid?
    assert page.errors[:position].empty?

    page.position = 100
    assert page.valid?
    assert page.errors[:position].empty?

    page.save
    assert_not_nil page.position
  end

  test "pages are loaded in the correct order" do
    page_list = []

    10.times do
      page = FactoryBot.build(:page)
      page.user = @user
      page.move_to_top
      page.save!
      page_list.insert(0, page.title)
    end

    assert_equal 10, @user.pages.size
    @user.pages.each do |page|
      title = page_list.shift
      assert_equal title, page.title
    end
  end

  test "page should_show_for" do
    page = FactoryBot.build(:page, user: @user)

    other_user = FactoryBot.build(:user)

    assert page.should_show_for? nil
    assert page.should_show_for? other_user
    assert page.should_show_for? @user

    page.is_private = true
    page.save!

    assert_not page.should_show_for? nil
    assert_not page.should_show_for? other_user
    assert page.should_show_for? @user
  end
end
