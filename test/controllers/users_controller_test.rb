require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
  end
  
  test "should show user" do
    get :show, params: { id: @user.id }
    assert_response :success
    assert_template :show
  end
  
  test "should show first page, if user has one" do
    5.times do |index|
      page = FactoryGirl.build(:page)
      page.title = index
      page.user = @user
      page.save!
    end
    
    get :show, params: { id: @user.id }
    assert_not_nil assigns[:page]
    assert_equal @user.pages.first.title, assigns[:page].title
    
    @user.pages.destroy_all
    @user.reload
    get :show, params: { id: @user.id }
    assert_equal 0, @user.pages.size
    #assert_nil assigns[:page]
    
  end
  
  test "should show a page list with as many items as pages" do
    page = FactoryGirl.build(:page)
    page.title = "Page"
    page.user = @user
    page.save!
    
    get :show, params: { id: @user.id }
    assert_select '#page_list' do
      assert_select 'li', @user.pages.count
    end
  end
  
  test "looking at your own settings page should work" do
    get :settings, params: { id: @user.id }
    assert_redirected_to new_user_session_path
    sign_in @user

    get :settings, params: { id: @user.id }
    assert_response :success
    assert_template :settings
  end
  
  test "you can't look at someone else's settings page" do
    sign_in @user
    get :settings, params: { id: @user2.id }
    assert_response :forbidden
    
  end
  
  test "you can export your own data" do
    get :export_data, params: { id: @user.id }
    assert_redirected_to new_user_session_path
    sign_in @user
    
    get :export_data, params: { id: @user.id }
    assert_response :success
  end
  
  test "can't export someone else's data" do
    sign_in @user2
    
    get :export_data, params: { id: @user.id }
    assert_response :forbidden
  end
end
