require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = categories(:drinks)
    @user = users(:one)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should get new" do
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, category: { name: @category.name + "_new", user_id: @user.id }, user_id: @user.id
    end

    assert_redirected_to user_category_path(@user.id, assigns(:category))
  end

  test "should show category" do
    get :show, id: @category, user_id: @user.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @category, user_id: @user.id
    assert_response :success
  end

  test "should update category" do
    put :update, id: @category, category: { name: @category.name, user_id: @user.id }, user_id: @user.id
    assert_redirected_to user_category_path(@user.id, assigns(:category))
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category, user_id: @user.id
    end

    assert_redirected_to user_categories_path
  end
  
  test "invalid category shows an error" do
    assert_no_difference('Category.count') do
      post :create, category: { name: @category.name }, user_id: @user.id
    end
    assert_response :success
    assert_select '#error_explanation'
  end
  
  test "category without a user id" do
    assert_no_difference('Category.count') do
      assert_raise ActionController::RoutingError do
        post :create, category: {name: @category.name}
      end
    end
  end
  
  test "category with an invalid user id" do
    assert_no_difference('Category.count') do
      assert_raise ActiveRecord::RecordNotFound do
        post :create, category: {name: @category.name}, user_id: 'non_existent_user'
      end
    end
  end
end
