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
    assert_equal '0', assigns[:page].title
    
  end
end
