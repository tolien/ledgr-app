require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  setup do
    @user =  FactoryBot.create(:user)
    @item = FactoryBot.create(:item, user: @user)
    @entry =  FactoryBot.create(:entry, item: @item)
    
    @user2 =  FactoryBot.create(:user)
  end

  test "should get index" do
    get :index, params: { user_id: @user.id }
    assert_not @user.is_private
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should get new" do
    sign_in @user
    get :new, params: { user_id: @user.id }
    assert_response :success
  end

  test "should create entry" do
    sign_in @user
    assert_difference('Entry.count') do
      post :create, params: { entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user.id}
    end

    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should show entry" do
    get :show, params: { id: @entry, user_id: @user.id }
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, params: { id: @entry, user_id: @user.id}
    assert_response :success
  end

  test "should update entry" do
    sign_in @user
    put :update, params: { id: @entry, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user.id }
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should destroy entry" do
    sign_in @user
    assert_difference('Entry.count', -1) do
      delete :destroy, params: { id: @entry, user_id: @user.id }
    end

    assert_redirected_to user_entries_path(user_id: @user.id)
  end

  test "shouldn't be able to delete an entry belonging to another user" do
    sign_in @user2
    assert_no_difference('Entry.count') do
      delete :destroy, params: { id: @entry, user_id: @user.id }
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to create an entry for another user" do
    sign_in @user
    
    get :new, params: { user_id: @user2.id }
    assert_response(:forbidden)
    
    assert_no_difference('Entry.count') do
      post :create, params: { entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user2.id }
    end
    assert_response(:forbidden)
  end
  
  test "shouldn't be able to update an entry belonging to another user" do
    sign_in @user
    put :update, params: { id: @entry, entry: { datetime: @entry.datetime, quantity: @entry.quantity, item_id: @item.id }, user_id: @user2.id }
    assert_response(:forbidden)
    assert_equal @entry, assigns(:entry)
  end
  
  test "should get JSON index" do
    get :index, format: :json, params: { user_id: @user.id }
    assert_response :success
    assert_not_nil assigns(:entries)

    result = JSON.parse(@response.body)
    assert_not_nil result['entries']
    assert_equal @user.entries.size, result['entries'].size
  end
  
  test "list entries should redirect to login or show 403 for private users" do
    @user.is_private = true
    @user.save!
    
    get :index, params: { user_id: @user.id }
    assert_redirected_to new_user_session_path
    
    sign_in @user2
    get :index, params: { user_id: @user.id }
    assert_response :forbidden
  end

  test "show entry should redirect login or forbidden for private users" do
    @user.is_private = true
    @user.save!

    get :show, params: { id: @entry, user_id: @user.id }
    assert_redirected_to new_user_session_path
    
    sign_in @user2
    get :show, params: { id: @entry, user_id: @user.id }
    assert_response :forbidden
  end

  
end
