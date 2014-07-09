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
      categories: ['fruit'],
      quantity: 1.0,
      datetime: 'Sun Apr 27 12:42:03 UTC 2014'.to_datetime
      },
      {
      name: 'orange',
      categories: ['drinks']
      }
    ]
    
    @import_header = "name,date,amount,categories"
    @tricky_line = "orange,Sun Apr 27 12:42:03 UTC 2014,1.0,fruit"
    
    @tricky_line_parsed = { 'name' => 'orange', 'date' => 'Sun Apr 27 12:42:03 UTC 2014', 'amount' => '1.0', 'categories' => 'fruit' }
  end
  
  test "single item import" do
    import = Importer.new
    assert_difference('@user.categories.size', 1) do
      assert_difference('@user.items.size', 1) do
        import.import_item_categories(@user.id, @single_import)
      end
    end
  end
  
  test "items and categories imported properly" do
    importer = Importer.new
    assert_difference('@user.categories.size', 2) do
      assert_difference('@user.items.size', 2) do
        importer.import_item_categories(@user.id, @test_import)
      end
    end    
  end
  
  test "two items with identical names but different categories are created" do
    importer = Importer.new
    assert_difference('@user.items.size', 2) do
      importer.import_item_categories(@user.id, @tricky_import)    
    end    
  end
  
  test "category-item associations set up properly" do
    importer = Importer.new
    importer.import_item_categories(@user.id, @test_import)
    @test_import.each do |item|
        imported_item = Item.where('name = ? AND user_id = ?', item[:name], @user.id)
        #assert_equal 1, imported_item.count, "There should be one item called #{item[:name]}"
        imported_item = imported_item.first
        #assert_equal item[:categories].count, imported_item.categories.count
                 
        imported_item.categories.each do |category|
          #assert item[:categories].include? category
        end
    end
  end
  
  test "importer merges items properly" do
    importer = Importer.new
    
  end
  
  test "parses a row of CSV text correctly" do
    importer = Importer.new
    assert_equal @tricky_import[0], importer.handle_line(@tricky_line_parsed)
  end
end
