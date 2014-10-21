require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  setup do
    @entry = entries(:entryone)
    @user = users(:one)
    @user2 = users(:two)
    @item = items(:water)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should get new" do
    sign_in @user
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should create entry" do
    sign_in @user
    assert_difference('Entry.count') do
      post :create, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user.id
    end

    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should show entry" do
    get :show, id: @entry, user_id: @user.id
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @entry, user_id: @user.id
    assert_response :success
  end

  test "should update entry" do
    sign_in @user
    put :update, id: @entry, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user.id
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should destroy entry" do
    sign_in @user
    assert_difference('Entry.count', -1) do
      delete :destroy, id: @entry, user_id: @user.id
    end

    assert_redirected_to user_entries_path(user_id: @user.id)
  end

  test "shouldn't be able to delete an entry belonging to another user" do
    sign_in @user2
    assert_no_difference('Entry.count') do
      delete :destroy, id: @entry, user_id: @user.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create an entry for another user" do
    sign_in @user
    
    get :new, user_id: @user2.id
    assert_response(:forbidden)
    
    assert_no_difference('Entry.count') do
      post :create, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user2.id
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update an entry belonging to another user" do
    sign_in @user
    put :update, id: @entry, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user2.id
    assert_response(:forbidden)
    assert_equal @entry, assigns(:entry)
  end
  
  test "quick entry should create an entry for an item that already exists" do
    sign_in @user
    assert_difference('Entry.count') do
      post :create, datetime: @entry.datetime, quantity: 2, item_name: @item.name, user_id: @user.id, class: "quick_entry"
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end
  
  test "quick entry should create the item if it does not exist" do
    sign_in @user
    
    assert_difference('Item.count') do
      assert_difference('Entry.count') do
        post :create, datetime: @entry.datetime, quantity: 2, item_name: @item.name + "_", user_id: @user.id, class: "quick_entry"
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end
  
  test "quick entry should handle item names containing colons" do
    sign_in @user
  end
  
  test "if quantity is not specified, should default to 1" do
    sign_in @user
  end
  
  test "if quantity is not numeric, should default to 0" do
    sign_in @user
  end
  
end
