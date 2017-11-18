require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:owned_page, user: @user)
    @user2 = FactoryBot.create(:user)
  end
  
  test "no index route" do
    assert_raises(ActionController::UrlGenerationError) do
      get "/#{@user.slug}/pages"
    end
  end
  
  test "should show page" do
    get :show, params: { id: @page, user_id: @user.id }
    assert_response :success
  end

  test "should log in to destroy page" do
    assert_no_difference('Page.count') do
      delete :destroy, params: { id: @page, user_id: @user.id }
    end

    assert_redirected_to new_user_session_path
  end
  
  test "should destroy page once logged in" do
    sign_in @user
    assert_difference('Page.count', -1) do
      delete :destroy, params: { id: @page, user_id: @user.id }
    end

#    assert_redirected_to user_items_path(@user.id)
  end

  test "shouldn't be able to delete a page belonging to another user" do
    sign_in @user2
    assert_no_difference('Page.count') do
      delete :destroy, params: { id: @page, user_id: @user.id }
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create a page for another user" do
    sign_in @user
    assert_no_difference('Page.count') do
      post :create, params: { page: { title: @page.title + "_new", user_id: @user2.id }, user_id: @user2.id }
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update a page belonging to another user" do
    sign_in @user2
    put :update, params: { id: @page.id, page: { title: @page.title + "_changed", user_id: @user.id }, user_id: @user.id }
    assert_response(:forbidden)
    assert_equal @page, assigns(:page)
  end

  test "should update page" do
    sign_in @user
    put :update, params: { id: @page.id, page: { title: @page.title + "_changed", user_id: @user.id }, user_id: @user.id }

    @page.title = @page.title + "_changed"
    # saving page to update the slug
    @page.save!

    assert_redirected_to user_page_path(@user, @page)
    assert_equal @page, assigns(:page)
  end
  
  test "should choke on an invalid page" do
    sign_in @user
    put :update, params: {id: @page.id, page: { title: @page.title, user_id: nil }, user_id: @user.id}
    assert_template 'edit'
  end
  
  test "should create page" do
    sign_in @user
    assert_difference('@user.pages.size') do
      put :create, params: { page: { title: @page.title, user_id: @user.id }, user_id: @user.id }
    end
  end

  test "can't create an invalid page" do
    sign_in @user
    assert_no_difference('@user.pages.size') do
      put :create, params: { id: @page.id, page: { title: @page.title, user_id: nil }, user_id: @user.id }
    end
    assert_template 'new'

  end
  
end
