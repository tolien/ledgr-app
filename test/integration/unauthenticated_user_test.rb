require 'test_helper'

class UnauthenticatedUserTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "user browsing entries pages" do
     get "/#{users(:one).username}/entries"
     assert_response :success
     assert_template "index"
     assert_select 'table' do
       assert_select 'tr', users(:one).entries.count
       assert_select 'a[data-method="delete"]', 0
     end
  end
  
  test "user browsing items pages" do
     get "/#{users(:one).username}/items"
     assert_response :success
     assert_template "index"
     assert_select 'table tr', users(:one).items.count
     
     item_url = "/#{users(:one).username}/items/#{items(:tea).id}"
     get item_url
     assert_response :success
     assert_template "show"     
     assert_select 'a[data-method="delete"]', 0
     assert_select 'a[href="#{item_url}"]', 0
  end
  
  test "user browsing category pages" do
    get "#{users(:one).username}/categories"
    assert_response :success
    assert_template "index"
  end
end
