require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = categories(:drinks)
    @user = users(:one)
    @user2 = users(:two)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should be required to login to get new" do
    get :new, user_id: @user.id
    assert_redirected_to new_user_session_path
  end
  
  test "should be able to get new once logged in" do
    sign_in @user
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should require auth to create category" do
    assert_no_difference('Category.count') do
      post :create, category: { name: @category.name + "_new", user_id: @user.id }, user_id: @user.id
    end

    assert_redirected_to new_user_session_path
  end
    
  test "should create category once authenticated" do
    sign_in @user
    assert_difference('Category.count') do
      post :create, category: { name: @category.name + "_new", user_id: @user.id }, user_id: @user.id
    end
    assert_redirected_to user_category_path(@user.id, assigns(:category))
  end

  test "should show category" do
    Rails.logger.debug("Category id: #{@category.id}")
    get :show, id: @category, user_id: @user.id
    assert_response :success
  end

  test "should have to login to edit" do
    Rails.logger.debug("Category id: #{@category.id}")
    get :edit, id: @category, user_id: @user.id

    assert_redirected_to new_user_session_path
  end
  
  test "should get edit once logged in" do
    sign_in @user
    Rails.logger.debug("Category id: #{@category.id}")
    get :edit, id: @category, user_id: @user.id
    assert_response :success
  end

  test "should login to update category" do
    put :update, id: @category, category: { name: @category.name, user_id: @user.id }, user_id: @user.id
    assert_redirected_to new_user_session_path
  end
  
  test "should update category" do
    sign_in @user
    put :update, id: @category, category: { name: @category.name + "_changed", user_id: @user.id }, user_id: @user.id
    assert_redirected_to user_category_path(@user, assigns(:category))
    assert_equal @category, assigns(:category)
  end

  test "should require login to destroy category" do
    assert_no_difference('Category.count') do
      delete :destroy, id: @category, user_id: @user.id
    end
    
    assert_redirected_to new_user_session_path
  end
  
  test "should destroy category once logged in" do
    sign_in @user
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category, user_id: @user.id
    end
    assert_redirected_to user_categories_path
  end
  
  test "invalid category shows an error" do
    sign_in @user
    assert_no_difference('Category.count') do
      post :create, category: { name: @category.name }, user_id: @user.id
    end
    assert_response :success
    assert_select '#error_explanation'
  end
  
  test "category without a user id" do
    sign_in @user
    assert_no_difference('Category.count') do
      assert_raise ActionController::RoutingError do
        post :create, category: {name: @category.name}
      end
    end
  end
  
  test "category with an invalid user id" do
    sign_in @user
    assert_no_difference('Category.count') do
      assert_raise ActiveRecord::RecordNotFound do
        post :create, category: {name: @category.name}, user_id: 'non_existent_user'
      end
    end
  end
  
  test "shouldn't be able to delete another user's categories" do
    sign_in @user2
    assert_no_difference('Category.count') do
      delete :destroy, id: @category, user_id: @user.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create a category for another user" do
    sign_in @user
    get :new, user_id: @user2.id
    assert_response(:forbidden)
    
    assert_no_difference('Category.count') do
      post :create, category: { name: @category.name + "_new", user_id: @user2.id }, user_id: @user2.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update a category belonging to another user" do
    sign_in @user2
    put :update, id: @category, category: { name: @category.name + "_changed", user_id: @user.id }, user_id: @user.id
    assert_response(:forbidden)
    assert_equal @category, assigns(:category)
  end

end
