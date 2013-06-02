require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @item = items(:water)
    @user = users(:one)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post :create, user_id: @item.user.id, item: { name: @item.name + "1" }
    end

    assert_redirected_to user_items_path(@item.user.id)
    assert_select('table #itemlist tr', @item.user.items.count)
  end

  test "should show item" do
    get :show, id: @item, user_id: @user.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item, user_id: @user.id
    assert_response :success
  end

  test "should update item" do
    put :update, id: @item, item: { name: @item.name }, user_id: @user.id
    assert_redirected_to user_item_path(@user.id, assigns(:item))
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item, user_id: @user.id
    end

    assert_redirected_to user_items_path(@user.id)
  end
end
