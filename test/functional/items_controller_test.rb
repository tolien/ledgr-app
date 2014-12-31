require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @user =  FactoryGirl.create(:user)
    @category =  FactoryGirl.create(:category, user: @user)
    @item =  FactoryGirl.create(:item, user: @user, categories: [@category])
    @user2 =  FactoryGirl.create(:user)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should login to get new" do
    get :new, user_id: @user.id
    assert_redirected_to new_user_session_path
  end
  
  test "should get new once logged in" do
    sign_in @user
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should login to create item" do
    assert_no_difference('Item.count') do
      post :create, user_id: @item.user.id, item: { name: @item.name + "1" }
    end

    assert_redirected_to new_user_session_path
    
  end

  test "should create item once authenticated" do
    sign_in @user
    assert_difference('Item.count') do
      post :create, user_id: @item.user.id, item: { name: @item.name + "1" }
    end

    assert_redirected_to user_items_path(@item.user.id)
  end

  test "should show item" do
    get :show, id: @item, user_id: @user.id
    assert_response :success
  end

  test "should have to log in to edit" do
    get :edit, id: @item, user_id: @user.id
    assert_redirected_to user_session_path
  end

  test "should get edit once logged in" do
    sign_in @user
    get :edit, id: @item, user_id: @user.id
    assert_response :success
  end

  test "should login to update item" do
    put :update, id: @item, item: { name: @item.name }, user_id: @user.id
    assert_redirected_to new_user_session_path
  end

  test "should update item once logged in" do
    sign_in @user
    put :update, id: @item, item: { name: @item.name }, user_id: @user.id
    assert_redirected_to user_item_path(@user.id, assigns(:item))
  end

  test "should log in to destroy item" do
    assert_no_difference('Item.count') do
      delete :destroy, id: @item, user_id: @user.id
    end

    assert_redirected_to new_user_session_path
  end
  
  test "should destroy item once logged in" do
    sign_in @user
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item, user_id: @user.id
    end

    assert_redirected_to user_items_path(@user.id)
  end
  
  test "updated item should retain categories" do
    sign_in @user
    @item.add_category(@category)
    assert Item.find(@item.id).categories.include? @category   

    put :update, id: @item, item: { name: @item.name }, user_id: @user.id
    assert_redirected_to user_item_path(@user.id, assigns(:item))      

    assert Item.find(@item.id).categories.include? @category   
    assert @item.categories.include? @category
  end
  
  test "item created from the categories screen should have the category set" do
    sign_in @user
    name = @item.name + "1"
    assert_difference('@category.items.count') do
      assert_difference('Item.count') do
        post :create, user_id: @user.id, item: { name: name, category_id: @category.id}
      end
    end
    
    new_item = Item.where('name = ? and user_id = ?', name, @user.id).first
    assert !new_item.nil?
    assert @category.items.include? new_item

    assert_redirected_to user_category_path(@user.id, @category.id)
  end

  test "shouldn't be able to delete an item belonging to another user" do
    sign_in @user2
    assert_no_difference('Item.count') do
      delete :destroy, id: @item, user_id: @user.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create an item for another user" do
    sign_in @user
    assert_no_difference('Item.count') do
      post :create, item: { name: @item.name + "_new", user_id: @user2.id }, user_id: @user2.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update an item belonging to another user" do
    sign_in @user2
    put :update, id: @item, item: { name: @item.name + "_changed", user_id: @user.id }, user_id: @user.id
    assert_response(:forbidden)
    assert_equal @item, assigns(:item)
  end
  
  test "should handle an empty category_id" do
    sign_in @user
    assert_difference('Item.count') do
      post :create, user_id: @item.user.id, item: { name: @item.name + "1", category_id: ""}
    end

    assert_redirected_to user_items_path(@item.user.id)
  end
  

end
