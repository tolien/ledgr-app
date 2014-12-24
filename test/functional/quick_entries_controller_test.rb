require 'test_helper'

class QuickEntriesControllerTest < ActionController::TestCase
  setup do
    @entry = entries(:entryone)
    @user = users(:one)
    @user2 = users(:two)
    @item = items(:water)
  end

  test "quick entry should create an entry for an item that already exists" do
    sign_in @user
    
    assert_difference('@user.entries.count') do
      assert_difference('@item.entries.count') do
        post :create, datetime: @entry.datetime, quantity: 2, item_name: @item.name, user_id: @user.id
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    @item.entries.reload
    new_entry = @item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 2.0, new_entry.quantity
  end
  
  test "quick entry should create the item if it does not exist" do
    sign_in @user
    
    assert_difference('@user.items.count') do
      assert_difference('@user.entries.count') do
        post :create, datetime: @entry.datetime, quantity: 2, item_name: @item.name + "_", user_id: @user.id
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    new_item = Item.where(name: @item.name + "_").first
    new_item.entries.reload
    new_entry = new_item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 2.0, new_entry.quantity
    assert_equal new_item.name, new_entry.item.name
  end
  
  test "quick entry should handle item names containing colons" do
    sign_in @user
    colon_item = @item.clone
    colon_item.name = "2001: A Space Odyssey"
    
    assert_difference('@user.items.count') do
      assert_difference('@user.entries.count') do
        post :create, datetime: @entry.datetime, quantity: 2, item_name: colon_item.name, user_id: @user.id
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    new_item = Item.where(name: colon_item.name).first
    new_item.entries.reload
    new_entry = new_item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 2.0, new_entry.quantity
    assert_equal new_item.name, new_entry.item.name
  end
  
  test "if quantity is not specified, should default to 1" do
    sign_in @user

    assert_difference('@user.entries.count') do
      assert_difference('@item.entries.count') do
        post :create, datetime: @entry.datetime, item_name: @item.name, user_id: @user.id, class: "quick_entry"
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    @item.entries.reload
    new_entry = @item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 1.0, new_entry.quantity
  end
  
  test "if quantity is not numeric, should default to 0" do
    sign_in @user

    assert_difference('@user.entries.count') do
      assert_difference('@item.entries.count') do
        post :create, datetime: @entry.datetime, item_name: @item.name, quantity: "wibble", user_id: @user.id, class: "quick_entry"
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    @item.entries.reload
    new_entry = @item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 0, new_entry.quantity
  end
end
