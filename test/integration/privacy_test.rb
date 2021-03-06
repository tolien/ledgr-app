require "test_helper"

class PrivacyTest < ActionDispatch::IntegrationTest
  fixtures :all

  def sign_in(user, password)
    post user_session_path, params: { user: { username: user.username, password: password } }
    follow_redirect!
  end

  def setup
    @user = FactoryBot.create(:user, password: "password", password_confirmation: "password")
    @other_user = FactoryBot.create(:user, password: "password", password_confirmation: "password")
    @category = FactoryBot.create(:category, user: @user)
    @item = FactoryBot.create(:item, user: @user, categories: [@category])

    @page_one = FactoryBot.create(:page, user: @user)
    @page_two = FactoryBot.create(:page, user: @user)

    @display = FactoryBot.create(:display, page: @page_one)
    @display_type = DisplayTypes::StreamGraph.first
    if @display_type.nil?
      @display_type = DisplayTypes::StreamGraph.new
      @display_type.name = "Streamgraph"
      @display_type.save!
    end
  end

  test "private user has a padlock beside their username" do
    get user_path(@user)
    assert_select ".navbar .navbar-text span.glyphicon-lock", false

    @user.is_private = true
    @user.save!

    get user_path(@user)
    assert_select ".navbar .navbar-text span.glyphicon-lock"
  end

  test "private pages aren't visible to other users" do
    @page_one.update(is_private: true)
    get user_path(@user)
    assert_select "#page_list li.nav-item", 1
  end

  test "private pages have a padlock beside their name if owned by the current user" do
    get user_path(@user)
    assert_select "#page_list li.nav-item" do |nav_item|
      assert_select nav_item, "span.glyphicon-lock", false
    end

    sign_in @user, "password"

    @page_one.update(is_private: true)
    get user_path(@user)

    assert_select "#page_list li.nav-item", 2
    assert_select "#page_list li.nav-item span.glyphicon-lock", 1

    @page_two.update(is_private: true)
    get user_path(@user)

    assert_select "#page_list li.nav-item", 2
    assert_select "#page_list li.nav-item span.glyphicon-lock", 2
  end

  test "can't view a private display unless you're the owner" do
    get user_page_path(@user, @page_one)
    assert_select ".displays #display_#{@display.id}"

    @display.update(is_private: true)
    get user_page_path(@user, @page_one)

    @display.display_type = @display_type
    @display.save!
    get user_display_path(@user, @display, format: :json)
    assert_response :forbidden

    sign_in(@user, "password")
    get user_page_path(@user, @page_one)
    assert_select ".displays #display_#{@display.id}"

    get user_display_path(@user, @display, format: :json)
    assert_response :success
  end

  test "can't view a private page unless you're the owner" do
    get user_page_path(@user, @page_one)
    assert_response :success

    sign_in(@user, "password")
    get user_page_path(@user, @page_one)
    assert_response :success

    @page_one.update(is_private: true)
    get user_page_path(@user, @page_one)
    assert_response :success

    delete destroy_user_session_path(@user)
    get user_page_path(@user, @page_one)
    assert_redirected_to new_user_session_path

    sign_in(@other_user, "password")
    get user_page_path(@other_user, @page_one)
    assert_response :forbidden
  end
end
