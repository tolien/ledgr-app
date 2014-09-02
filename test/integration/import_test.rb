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
      entries: [
        {
          quantity: 1.0,
          datetime: 'Sun Apr 27 12:42:03 UTC 2014'.to_datetime
        }
      ]
      },
      {
      name: 'orange',
      categories: ['drinks']
      }
    ]
    
    @import_header = "name,date,amount,categories"
    @tricky_line = "orange,Sun Apr 27 12:42:03 UTC 2014,1.0,fruit"
    
    @tricky_line_parsed = { 'name' => 'orange', 'date' => 'Sun Apr 27 12:42:03 UTC 2014', 'amount' => '1.0', 'categories' => 'fruit' }
    
    @test_line_one = { 'name' => 'orange', 'date' => 'Apr 27 12:42:03 UTC 2014', 'amount' => '1.0', 'categories' => 'fruit' }
    @test_line_two = { 'name' => 'orange', 'date' => 'Apr 28 13:12:15 UTC 2014', 'amount' => '2.0', 'categories' => 'fruit' }
    @test_line_three = { 'name' => 'orange', 'date' => 'Apr 28 13:12:15 UTC 2014', 'amount' => '2.0', 'categories' => 'drinks' }
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
        Rails.logger.debug("Looking for item for user_id #{@user.id} with name #{item[:name]}")
        assert_equal 1, imported_item.count, "There should be one item called #{item[:name]}"
        imported_item = imported_item.first
        assert_equal item[:categories].count, imported_item.categories.count, "Imported item should have #{item[:categories].count} categories"
        
        imported_item.categories.each do |category|
          assert item[:categories].include?(category.name), "Imported item has category #{category.name} which wasn't in the initial list"
        end
    end
  end
  
  test "parses a row of CSV text correctly" do
    importer = Importer.new
    assert_equal @tricky_import[0], importer.handle_line(@tricky_line_parsed)
  end
  
  test "importer merges items properly" do
    importer = Importer.new
    
    assert_nil importer.merge @test_line_one, {}
    
    line_one = importer.handle_line @test_line_one
    line_two = importer.handle_line @test_line_two
    line_three = importer.handle_line @test_line_three
    
    merged = importer.merge(line_one, [])
    assert_equal 1, merged.count
    assert_equal 1, merged.first[:entries].count
    
    merged = importer.merge(line_two, merged)    
    assert_equal 1, merged.count, "the two items should be merged into one"
    assert_equal 2, merged.first[:entries].count, "the merged item should have both entries"
    
    assert_equal 1, line_one[:entries].count, "line_one hasn't been mutated along the way"
    
    merged = importer.merge(line_three, merged)
    assert_equal 2, merged.count, "should have added a new item"
  end
end
