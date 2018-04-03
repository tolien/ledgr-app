require 'test_helper'

class QuickEntriesControllerTest < ActionController::TestCase
  setup do
    @user =  FactoryBot.create(:user)
    @item =  FactoryBot.create(:item, user: @user)
    @entry =  FactoryBot.create(:entry, item: @item)
    
    @user2 =  FactoryBot.create(:user)
  end

  test "quick entry should create an entry for an item that already exists" do
    sign_in @user
    
    assert_difference('@user.entries.count') do
      assert_difference('@item.entries.count') do
        post :create, params: { datetime: @entry.datetime, quantity: 2, item_name: @item.name, user_id: @user.id }
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
        post :create, params: { datetime: @entry.datetime, quantity: 2, item_name: @item.name + "_", user_id: @user.id }
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
        post :create, params: { datetime: @entry.datetime, quantity: 2, item_name: colon_item.name, user_id: @user.id } 
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
        post :create, params: { datetime: @entry.datetime, item_name: @item.name, user_id: @user.id, class: "quick_entry" }
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
        post :create, params: { datetime: @entry.datetime, item_name: @item.name, quantity: "wibble", user_id: @user.id, class: "quick_entry" }
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    @item.entries.reload
    new_entry = @item.entries.reorder(created_at: :asc).last
    assert_not_nil new_entry
    assert_equal @entry.datetime, new_entry.datetime
    assert_equal 0, new_entry.quantity
  end
  
  test "shouldn't be able to quick-create an entry for someone else" do
    sign_in @user2
    
    assert_no_difference('@user.entries.count') do
      assert_no_difference('@item.entries.count') do
        post :create, params: { datetime: @entry.datetime, item_name: @item.name, user_id: @user.id }
      end
    end
    
    assert_response(:forbidden)
  end

  test "should be case-insensitive" do
    sign_in @user

    assert_no_difference('@user.items.count') do
      assert_difference('@user.entries.count', 3) do
        assert_difference('@item.entries.count', 3) do
          post :create, params: { datetime: @entry.datetime, item_name: @item.name.downcase, user_id: @user.id, class: "quick_entry" }
          post :create, params: { datetime: @entry.datetime, item_name: @item.name.upcase, user_id: @user.id, class: "quick_entry" }
          post :create, params: { datetime: @entry.datetime, item_name: @item.name, user_id: @user.id, class: "quick_entry" }
        end
      end
    end
    
    assert_redirected_to user_entry_path(@user.id, assigns(:entry))
    @item.entries.reload
    new_entries = @item.entries.reorder(created_at: :asc).where(datetime: @entry.datetime).where.not(created_at: @entry.created_at)
    assert_not_nil new_entries
    assert_equal 3, new_entries.size
  end
end
