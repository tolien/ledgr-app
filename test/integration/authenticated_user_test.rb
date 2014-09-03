require 'test_helper'

class AuthenticatedUserTestTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def sign_in(user, password)
    post_via_redirect user_session_path, user: {username: user.username, password: password}
  end
    
  def setup
    @user_one = users(:one)
    @category = categories(:drinks)
    @item = @category.items.first
    sign_in @user_one, 'password'
  end
  
  test "the welcome text should be shown in the header" do
    get "/#{@user_one.username}/categories"
    assert_select "p.navbar-text.pull-left", text: /Welcome, #{@user_one.username}/ do |element|
      assert_select "a", text: "sign out"
    end
  end
  
  test "browse the category pages" do
    get "/#{@user_one.username}/categories"
    assert_select 'table' do
      assert_select 'tr', @user_one.categories.size
      assert_select 'a[data-method="delete"]', @user_one.categories.size
    end
    
    get "/#{@user_one.username}/categories/#{@category.id}"
    assert_template 'show'
    assert_select 'a[data-method="delete"]'
  end
  
  test "create items from the category show page" do
    get "/#{@user_one.username}/items/new?category_id=#{@category.id}"
    assert_response :success
    assert_template 'new'
    assert_select "input#item_name"
    assert_select "input#item_category_id" do
      assert_select '[value=?]', @category.id.to_s
    end
  end
  
  test "quick entry form shown" do
    get "/#{@user_one.username}/items"
    assert_quick_entry()
    
    get "/#{@user_one.username}/categories"
    assert_quick_entry()
    
    get "/#{@user_one.username}/entries"
    assert_quick_entry()
  end
  
  def assert_quick_entry()
    assert_select "#quick_entry"
  end
end
