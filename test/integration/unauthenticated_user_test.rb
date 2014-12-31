require 'test_helper'

class UnauthenticatedUserTest < ActionDispatch::IntegrationTest
  fixtures :all
    
  def setup
    @user = FactoryGirl.create(:user)
    @category = FactoryGirl.create(:category, user: @user)
    @item = FactoryGirl.create(:item, user: @user, categories: [@category])
    
  end
  
  test "user browsing entries pages" do
     get "/#{@user.slug}/entries"
     assert_response :success
     assert_template "index"
     assert_select 'table' do
       assert_select 'tr', @user.entries.count
       assert_select "a[data-method='delete']", 0
     end
  end
  
  test "user browsing items pages" do
     get "/#{@user.slug}/items"
     assert_response :success
     assert_template "index"
     assert_select 'table tr', @user.items.count
     
     item_url = "/#{@user.slug}/items/#{@item.id}"
     get item_url
     assert_response :success
     assert_template "show"     
     assert_select "a[data-method='delete']", 0
     assert_select 'a[href="#{item_url}"]', 0
  end
  
  test "user browsing category pages" do
    assert @user.categories.count > 0, "these tests are meaningless if the user has no categories"
    get "/#{@user.slug}/categories"
    assert_response :success
    assert_template "index"
    
    assert_select 'table' do
      assert_select 'tr', @user.categories.count
      assert_select "a[data-method='delete']", 0
    end
    
    item = FactoryGirl.create(:item, user: @user)
    category = FactoryGirl.create(:category, user: @user)
    item.add_category(category)
    get "/#{@user.slug}/categories/#{category.id}"
    assert_response :success
    assert_template "show"
  end
end
