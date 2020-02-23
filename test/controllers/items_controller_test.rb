require "test_helper"

class ItemsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @category = FactoryBot.create(:category, user: @user)
    @item = FactoryBot.create(:item, user: @user, categories: [@category])
    @user2 = FactoryBot.create(:user)
  end

  test "should get index" do
    get :index, params: { user_id: @user.id }
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should login to get new" do
    get :new, params: { user_id: @user.id }
    assert_redirected_to new_user_session_path
  end

  test "should get new once logged in" do
    sign_in @user
    get :new, params: { user_id: @user.id }
    assert_response :success
  end

  test "should login to create item" do
    assert_no_difference("Item.count") do
      post :create, params: { user_id: @item.user.id, item: { name: @item.name + "1" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "should create item once authenticated" do
    sign_in @user
    assert_difference("Item.count") do
      post :create, params: { user_id: @item.user.id, item: { name: @item.name + "1" } }
    end

    assert_redirected_to user_items_path(@item.user.id)
  end

  test "should show item" do
    get :show, params: { id: @item, user_id: @user.id }
    assert_response :success
  end

  test "should have to log in to edit" do
    get :edit, params: { id: @item, user_id: @user.id }
    assert_redirected_to user_session_path
  end

  test "should get edit once logged in" do
    sign_in @user
    get :edit, params: { id: @item, user_id: @user.id }
    assert_response :success
  end

  test "should login to update item" do
    put :update, params: { id: @item, item: { name: @item.name }, user_id: @user.id }
    assert_redirected_to new_user_session_path
  end

  test "should update item once logged in" do
    sign_in @user
    put :update, params: { id: @item, item: { name: @item.name }, user_id: @user.id }
    assert_redirected_to user_item_path(@user.id, assigns(:item))
  end

  test "should log in to destroy item" do
    assert_no_difference("Item.count") do
      delete :destroy, params: { id: @item, user_id: @user.id }
    end

    assert_redirected_to new_user_session_path
  end

  test "should destroy item once logged in" do
    sign_in @user
    assert_difference("Item.count", -1) do
      delete :destroy, params: { id: @item, user_id: @user.id }
    end

    assert_redirected_to user_items_path(@user.id)
  end

  test "updated item should retain categories" do
    sign_in @user
    @item.add_category(@category)
    assert Item.find(@item.id).categories.include? @category

    put :update, params: { id: @item, item: { name: @item.name }, user_id: @user.id }
    assert_redirected_to user_item_path(@user.id, assigns(:item))

    assert Item.find(@item.id).categories.include? @category
    assert @item.categories.include? @category
  end

  test "item created from the categories screen should have the category set" do
    sign_in @user
    name = @item.name + "1"
    assert_difference("@category.items.count") do
      assert_difference("Item.count") do
        post :create, params: { user_id: @user.id, item: { name: name, category_id: @category.id } }
      end
    end

    new_item = Item.where("name = ? and user_id = ?", name, @user.id).first
    assert !new_item.nil?
    assert @category.items.include? new_item

    assert_redirected_to user_category_path(@user.id, @category.id)
  end

  test "shouldn't be able to delete an item belonging to another user" do
    sign_in @user2
    assert_no_difference("Item.count") do
      delete :destroy, params: { id: @item, user_id: @user.id }
    end
    assert_response(:forbidden)
  end

  test "shouldn't be able to create an item for another user" do
    sign_in @user

    get :new, params: { user_id: @user2.id }
    assert_response(:forbidden)

    assert_no_difference("Item.count") do
      post :create, params: { item: { name: @item.name + "_new" }, user_id: @user2.id }
    end
    assert_response(:forbidden)
  end

  test "shouldn't be able to update an item belonging to another user" do
    sign_in @user2
    put :update, params: { id: @item, item: { name: @item.name + "_changed" }, user_id: @user.id }
    assert_response(:forbidden)
    assert_equal @item, assigns(:item)
  end

  test "should handle an empty category_id" do
    sign_in @user
    assert_difference("Item.count") do
      post :create, params: { user_id: @item.user.id, item: { name: @item.name + "1", category_id: "" } }
    end

    assert_redirected_to user_items_path(@item.user.id)
  end

  test "should handle a category_id for a category which doesn't exist" do
    sign_in @user
    assert_difference("Item.count") do
      category_id = @category.id
      @category.destroy
      assert_raises ActiveRecord::RecordNotFound do
        Category.find(category_id)
      end
      post :create, params: { user_id: @item.user.id, item: { name: @item.name + "1", category_id: category_id } }
    end

    assert_redirected_to user_items_path(@item.user.id)
  end

  test "should get JSON index" do
    get :index, format: :json, params: { user_id: @user.id }
    assert_response :success
    assert_not_nil assigns(:items)

    result = JSON.parse(@response.body)
    assert_not_nil result["items"]
    assert_equal @user.items.size, result["items"].size
  end

  test "list items should redirect to login or show 403 for private users" do
    @user.is_private = true
    @user.save!

    get :index, params: { user_id: @user.id }
    assert_redirected_to new_user_session_path

    sign_in @user2
    get :index, params: { user_id: @user.id }
    assert_response :forbidden
  end

  test "show item should redirect login or forbidden for private users" do
    @user.is_private = true
    @user.save!

    get :show, params: { id: @item, user_id: @user.id }
    assert_redirected_to new_user_session_path

    sign_in @user2
    get :show, params: { id: @item, user_id: @user.id }
    assert_response :forbidden
  end
end
