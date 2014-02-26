require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = FactoryGirl.create(:owned_page)
    @user = @page.user
    @user2 = users(:two)
  end
  
  test "no index route" do
    assert_raises(ActionController::RoutingError) do
      assert_recognizes({}, '/#{@page.user.username}/pages')
    end
  end
  
  test "should log in to destroy page" do
    assert_no_difference('Page.count') do
      delete :destroy, id: @page, user_id: @user.id
    end

    assert_redirected_to new_user_session_path
  end
  
  test "should destroy page once logged in" do
    sign_in @user
    assert_difference('Page.count', -1) do
      delete :destroy, id: @page, user_id: @user.id
    end

#    assert_redirected_to user_items_path(@user.id)
  end

  test "shouldn't be able to delete a page belonging to another user" do
    sign_in @user2
    assert_no_difference('Page.count') do
      delete :destroy, id: @page, user_id: @user.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create a page for another user" do
    sign_in @user
    assert_no_difference('Page.count') do
      post :create, page: { title: @page.title + "_new", user_id: @user2.id }, user_id: @user2.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update a page belonging to another user" do
    sign_in @user2
    put :update, id: @page.id, page: { title: @page.title + "_changed", user_id: @user.id }, user_id: @user.id
    assert_response(:forbidden)
    assert_equal @page, assigns(:page)
  end
  
end
