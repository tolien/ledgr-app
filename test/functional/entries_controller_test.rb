require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  setup do
    @entry = entries(:entryone)
    @user = users(:one)
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should get new" do
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should create entry" do
    assert_difference('Entry.count') do
      post :create, entry: { datetime: @entry.datetime, quantity: @entry.quantity }, user_id: @user.id
    end

    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should show entry" do
    get :show, id: @entry, user_id: @user.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @entry, user_id: @user.id
    assert_response :success
  end

  test "should update entry" do
    put :update, id: @entry, entry: { datetime: @entry.datetime, quantity: @entry.quantity }, user_id: @user.id
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
  end

  test "should destroy entry" do
    assert_difference('Entry.count', -1) do
      delete :destroy, id: @entry, user_id: @user.id
    end

    assert_redirected_to user_entries_path(user_id: @user.id)
  end
end
