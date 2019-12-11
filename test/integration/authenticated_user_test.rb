require 'test_helper'

class AuthenticatedUserTest < ActionDispatch::IntegrationTest
  def sign_in(user, password)
    post user_session_path, params: { user: {username: user.username, password: password} }
    follow_redirect!
  end
    
  def setup
    @user_one = FactoryBot.create(:user, password: 'password', password_confirmation: 'password')
    @category = FactoryBot.create(:category, user: @user_one)
    @item = FactoryBot.create(:item, user: @user_one, categories: [@category])
    sign_in @user_one, 'password'
  end
  
  test "the welcome text should be shown in the header" do
    get "/#{@user_one.slug}/categories"
    assert_select "p.navbar-text.pull-left", text: /Welcome, #{@user_one.username}/ do
      assert_select "a", text: /sign out/
    end
  end
  
  test "browse the category pages" do
    get "/#{@user_one.slug}/categories"
    assert_select 'table' do
      assert_select 'tr', @user_one.categories.size
      assert_select 'a[data-method="delete"]', @user_one.categories.size
    end
    
    get "/#{@user_one.slug}/categories/#{@category.id}"
    assert_template 'show'
    assert_select 'a[data-method="delete"]'
  end
  
  test "create items from the category show page" do
    get "/#{@user_one.slug}/items/new?category_id=#{@category.id}"
    assert_response :success
    assert_template 'new'
    assert_select "input#item_name"
    assert_select "input#item_category_id" do
      assert_select '[value=?]', @category.id.to_s
    end
  end
  
  test "quick entry form shown" do
    get "/#{@user_one.slug}/items"
    assert_quick_entry()
    
    get "/#{@user_one.slug}/categories"
    assert_quick_entry()
    
    get "/#{@user_one.slug}/entries"
    assert_quick_entry()
  end
  
  test "settings page" do
    get "/#{@user_one.slug}/settings"
    assert_response :success      
    assert_template "settings"
  end
  
  def assert_quick_entry()
    assert_select "#quick_entry" do
      assert_select "input.item_name"      
      assert_select "input.quantity"
      assert_select "input.datetime"
    end
  end
end
