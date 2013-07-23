require 'test_helper'

class AuthenticatedUserTestTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def sign_in(user, password)
    post_via_redirect user_session_path, username: user.username, password: password
  end
    
  def setup
    @user_one = users(:one)
    @category = categories(:drinks)
    @item = @category.items.first
    sign_in @user_one, 'password'
  end
  
  test "browse the category pages" do
    get "/#{@user_one.username}/categories"
    assert_select 'table' do
      assert_select 'tr', @user_one.categories.size
      assert_select 'a[data-method="delete"]', @user_one.categories.size
    end
  end
  
  test "create items from the category show page" do
    get "/#{@user_one.username}/categories/#{@category.id}"
    assert_template 'show'
    assert_select 'a[data-method="delete"]'
    
    get "/#{@user_one.username}/items/new?category_id=#{@category.id}"
    assert_template 'new'
    assert_select "input#item_category_id" do
      assert_select '[value=?]', @category.id.to_s
    end
  end
end
