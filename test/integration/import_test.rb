require 'test_helper'

class ImportTest < ActionDispatch::IntegrationTest
  fixtures :users
  
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
    
    @single_import = []
    @single_import << @test_import[0]
    
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
  
  test "single item import" do
    assert_difference('@user.categories.size', 1) do
      assert_difference('@user.items.size', 1) do
        import_item_categories(@user.id, @single_import)
      end
    end
  end
  
  test "items and categories imported properly" do
    assert_difference('@user.categories.size', 2) do
      assert_difference('@user.items.size', 2) do
        import_item_categories(@user.id, @test_import)
      end
    end    
  end
  
  test "two items with identical names but different categories are created" do
    assert_difference('@user.items.size', 2) do
      import_item_categories(@user.id, @tricky_import)    
    end    
  end
  
  test "category-item associations set up properly" do
    import_item_categories(@user.id, @test_import)
    @test_import.each do |item|
      
    end
  end
end
