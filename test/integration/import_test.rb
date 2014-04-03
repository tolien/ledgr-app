require 'test_helper'

class ImportTest < ActionDispatch::IntegrationTest
  fixtures :users
  include ApplicationHelper  
  
  def setup
    @user = users(:one)
    @test_import = [
      {
        name: 'tea',
        categories: ['drinks']
      },
      {
        name: 'beer',
        categories: ['drinks', 'alcohol']
      }
    ]
    @tricky_import = [
      {
      name: 'orange',
      categories: ['fruit']
      },
      {
      name: 'orange',
      categories: ['drinks']
      }
    ]
  end
  
  test "items and categories imported properly" do
    assert_difference('@user.categories.size', 2) do
      assert_difference('@user.items.size', 2) do
        import_item_categories(@user, @test_import)
      end
    end    
  end
  
  test "two items with identical names but different categories are created" do
    assert_difference('@user.items.size', 2) do
      import_item_categories(@user, @tricky_import)    
    end
    
  end
end
