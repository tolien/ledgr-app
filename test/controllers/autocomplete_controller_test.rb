require 'test_helper'

class AutocompleteControllerTest < ActionController::TestCase
  setup do
    @user =  FactoryGirl.create(:user)
  end
  
  test "autocomplete requires login" do
    get :index, format: :json
    assert_response(:unauthorized)
  end
  
  test "autocomplete should return results" do
    sign_in @user
    get :index, format: :json
  end
end
