require 'test_helper'

class UnauthenticatedUserTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "user browsing" do
     get "/#{users(:one).username}/entries"
     assert_response :success
     assert_template "index"
     assert_select 'table tr', users(:one).entries.count
     
     get "/#{users(:one).username}/items"
     assert_response :success
     assert_template "index"
     assert_select 'table tr', users(:one).items.count
  end
end
