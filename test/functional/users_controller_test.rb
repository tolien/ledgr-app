require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end
  
  test "should show user" do
    get :show, id: @user.id
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
    
    get :show, id: @user.id
    assert_not_nil assigns[:page]
    assert_equal @user.pages.first.title, assigns[:page].title
    
    @user.pages.destroy_all
    @user.reload
    get :show, id: @user.id
    assert_equal 0, @user.pages.size
    #assert_nil assigns[:page]
    
  end
  
  test "should show a page list with as many items as pages" do
    page = FactoryGirl.build(:page)
    page.title = "Page"
    page.user = @user
    page.save!
    
    get :show, id: @user.id
    assert_select '#page_list' do
      assert_select 'li', @user.pages.count
    end
  end
end
