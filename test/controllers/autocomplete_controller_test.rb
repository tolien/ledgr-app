require 'test_helper'

class AutocompleteControllerTest < ActionController::TestCase
  setup do
    @user =  FactoryBot.create(:user)
    @foo_item = FactoryBot.create(:item, name: 'foo', user_id: @user.id)
    @blahfoowibble_item = FactoryBot.create(:item, name: 'blahfoowibble', user_id: @user.id)
    @hmm_item = FactoryBot.create(:item, name: 'hmm', user_id: @user.id)
  end
  
  test "autocomplete requires login" do
    get :index, params: { format: :json }
    assert_response :unauthorized
  end

  test "autocomplete should return an empty list when nothing matched" do
    sign_in @user
    get :index, params: { format: :json, term: 'bar' }
    assert_response :ok
    assert_not_nil assigns :items
    assert_empty assigns :items
  end
    
  test "autocomplete should return results" do
    sign_in @user
    get :index, params: { format: :json, term: 'foo' }
    assert_response :ok
    assert_not_nil assigns :items
    assert_not_empty assigns :items
  end
  
  test "autocomplete results should be correct" do
    # should include everything that matches
    sign_in @user
    get :index, params: { format: :json, term: 'foo' }
    assert_response :ok
    assert_equal 2, assigns(:items).size
    assert_includes assigns(:items), @foo_item.name
    
    # but only items that match
    get :index, params: { format: :json, term: 'wibble' }
    assert_response :ok
    assert_equal 1, assigns(:items).size
    assert_includes assigns(:items), @blahfoowibble_item.name 
    assert_not_includes assigns(:items), @foo_item.name
  end
  
  test "autocomplete should be case insensitive" do
    sign_in @user
    get :index, params: {format: :json, term: 'FOO' }
    assert_response :ok
    assert_equal 2, assigns(:items).size
    assert_includes assigns(:items), @foo_item.name
  end
end
