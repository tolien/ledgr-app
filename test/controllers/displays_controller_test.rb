require 'test_helper'

class DisplaysControllerTest < ActionController::TestCase
  
  setup do
    @user = FactoryGirl.create(:user)
    
    @page = FactoryGirl.build(:page)
    @page.user_id = @user.id
    @page.save!
    
    @display = FactoryGirl.build(:display)
    @display.page_id = @page.id
    @display.save!
  end
  
  test "should get edit" do
    sign_in @user
    get :edit, params: { user_id: @user.id, id: @display.id }
    assert_response :success
  end

  test "should get create" do
    sign_in @user
    get :create, params: { user_id: @user.id } 
    assert_response :success
  end

  test "should get update" do
    sign_in @user
    get :update, params: { user_id: @user.id, id: @display.id }
    assert_response :success
  end

  test "should get show" do
    # sign_in @user
    get :show, params: { user_id: @user.id, id: @display.id }
    assert_response :success
  end
  
  test "should get destroy" do
    sign_in @user
    assert_difference('Display.count', -1) do
      get :destroy, params: { user_id: @user.id, id: @display.id }
    end
    assert_response :success
  end
  
  test "shouldn't be able to destroy someone else's displays" do
    user2 = FactoryGirl.create(:user)

    sign_in user2
    assert_no_difference('Display.count') do
      get :destroy, params: { user_id: @user.id, id: @display.id }
    end
    assert_response :forbidden
  end

end
