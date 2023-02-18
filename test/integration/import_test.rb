require "test_helper"

class ImportTest < ActionDispatch::IntegrationTest
  def setup
    @user = FactoryBot.create(:user)
    @test_import = [
      {
        name: "irn bru",
        categories: ["drinks"],
        entries: [
          {
            datetime: "Apr 28 13:12:15 UTC 2014".to_datetime,
            quantity: 2,
          },
          {
            datetime: "Apr 27 12:42:03 UTC 2014".to_datetime,
            quantity: 1,
          },
        ],
      },
      {
        name: "beer",
        categories: ["drinks", "alcohol"],
      },
    ]

    @single_import = []
    @single_import << @test_import[0]

    @tricky_import = [
      {
        name: "orange",
        categories: ["fruit"],
        entries: [
          {
            quantity: 1.0,
            datetime: "Sun Apr 27 12:42:03 UTC 2014".to_datetime,
          },
        ],
      },
      {
        name: "orange",
        categories: ["drinks"],
        entries: [
          {
            quantity: 2.0,
            datetime: "Wed Sept 17 12:12:07 UTC 2014".to_datetime,
          },
        ],
      },
    ]

    @import_header = "name,date,amount,categories"
    @tricky_line = "orange,Sun Apr 27 12:42:03 UTC 2014,1.0,fruit"
    @line_with_no_item = ",Sun Apr 27 12:42:03 UTC 2014,1.0,fruit"

    @tricky_line_parsed = { "name" => "orange", "date" => "Sun Apr 27 12:42:03 UTC 2014", "amount" => "1.0", "categories" => "fruit" }
    @tricky_line_spaces = { "name" => " orange ", "date" => "Sun Apr 27 12:42:03 UTC 2014", "amount" => "1.0", "categories" => " fruit " }

    @test_line_one = { "name" => "orange", "date" => "Sun Apr 27 12:42:03 UTC 2014", "amount" => "1.0", "categories" => "fruit" }
    @test_line_two = { "name" => "orange", "date" => "Sun Apr 28 13:12:15 UTC 2014", "amount" => "2.0", "categories" => "fruit" }
    @test_line_three = { "name" => "orange", "date" => "Sun Apr 28 13:12:15 UTC 2014", "amount" => "2.0", "categories" => "drinks" }
    
    @new_format_line_one = { "Name" => "orange", "Date" => "2014-04-27T12:42:03Z", "Amount" => "1.0", "Categories" => "fruit" }
    @new_format_line_two = { "Name" => "orange", "Date" => "2014-04-28T13:12:15Z", "Amount" => "2.0", "Categories" => "fruit" }
    @new_format_line_three = { "Name" => "orange", "Date" => "2014-04-28T13:12:15.007Z", "Amount" => "2.0", "Categories" => "drinks" }

    @importer = Importer.new
  end

  test "single item import" do
    assert_difference("@user.categories.count", 1) do
      assert_difference("@user.items.count", 1) do
        @importer.import_item_categories(@user.id, @single_import)
      end
    end
  end

  test "items and categories imported properly" do
    assert_difference("@user.categories.count", 2) do
      assert_difference("@user.items.count", 2) do
        @importer.import_item_categories(@user.id, @test_import)
      end
    end
  end

  test "two items with identical names but different categories are created" do
    assert_difference("@user.items.count", 2) do
      @importer.import_item_categories(@user.id, @tricky_import)
    end
  end

  test "category-item associations set up properly" do
    @importer.import_item_categories(@user.id, @test_import)
    @test_import.each do |item|
      imported_item = Item.where("name = ? AND user_id = ?", item[:name], @user.id)
      Rails.logger.debug("Looking for item for user_id #{@user.id} with name #{item[:name]}")
      assert_equal 1, imported_item.count, "There should be one item called #{item[:name]}"
      imported_item = imported_item.first
      assert_equal item[:categories].count, imported_item.categories.count, "Imported item should have #{item[:categories].count} categories"

      imported_item.categories.each do |category|
        assert item[:categories].include?(category.name), "Imported item #{imported_item.name} has category #{category.name} which wasn't in the initial list"
      end
    end
  end

  test "item-category associations set up for two items with the same name" do
    @importer.import_item_categories(@user.id, @tricky_import)

    item_name = @tricky_import[0][:name]
    imported_item = Item.where("name = ? AND user_id = ?", item_name, @user.id)
    assert_equal 2, imported_item.count, "There should be two items called #{item_name}"

    @tricky_import.each do |tricky_item|
      category = Category.where(name: tricky_item[:categories].first, user_id: @user.id)
      imported_item = category.first.items.first
      assert_equal tricky_item[:categories].count, imported_item.categories.count, "Imported item should have #{tricky_item[:categories].count} categories"

      imported_item.categories.each do |imported_category|
        assert tricky_item[:categories].include?(imported_category.name), "Imported item has category #{imported_category.name} which wasn't in the initial list"
      end
    end
  end

  test "parses a row of CSV text correctly" do
    assert_equal @tricky_import[0], @importer.handle_line(@tricky_line_parsed)
  end

  test "importer merges items properly" do
    assert_nil @importer.merge @test_line_one, {}

    line_one = @importer.handle_line @test_line_one
    line_two = @importer.handle_line @test_line_two
    line_three = @importer.handle_line @test_line_three

    merged = @importer.merge(line_one, [])
    assert_equal 1, merged.count
    assert_equal 1, merged.first[:entries].count

    merged = @importer.merge(line_two, merged)
    assert_equal 1, merged.count, "the two items should be merged into one"
    assert_equal 2, merged.first[:entries].count, "the merged item should have both entries"
    merged.first[:entries].each do |entry|
      assert_instance_of Hash, entry, "should be a Hash"
    end

    assert_equal 1, line_one[:entries].count, "line_one hasn't been mutated along the way"

    merged = @importer.merge(line_three, merged)
    assert_equal 2, merged.count, "should have added a new item"

    merged = @importer.merge(line_one, [])
    merged = @importer.merge(line_three, merged)
    merged = @importer.merge(line_two, merged)
    assert_equal 2, merged.count, "two items result from merging"
    assert 2, merged[0][:entries].count
    assert 1, merged[1][:entries].count
  end

  test "entries get persisted properly on import" do
    assert_difference("User.find(@user.id).entries.count", 2) do
      @importer.import_item_categories(@user.id, @test_import)
      @importer.import_entries(@user.id, @test_import)
    end
  end

  test "import_entry resolves the correct item" do
    assert_difference("User.find(@user.id).entries.count", 2) do
      @importer.import_item_categories(@user.id, @tricky_import)
      @importer.import_entries(@user.id, @tricky_import)
    end
  end

  test "leading and trailing spaces in item and category names are handled properly" do
    line_one = @importer.handle_line @tricky_line_spaces

    assert_equal line_one, @tricky_import[0]
  end

  test "running an import twice with the same input shouldn't duplicate items or categories" do
    @importer.import_item_categories(@user.id, @test_import)
    @importer.import_entries(@user.id, @test_import)

    assert_no_difference("@user.categories.count") do
      assert_no_difference("@user.items.count") do
        @importer.import_item_categories(@user.id, @test_import)
        @importer.import_entries(@user.id, @test_import)
      end
    end
  end

  test "running an import twice with the same input shouldn't duplicate entries" do
    @importer.import_item_categories(@user.id, @test_import)
    @importer.import_entries(@user.id, @test_import)

    assert_no_difference("@user.entries.count") do
      @importer.import_item_categories(@user.id, @test_import)
      @importer.import_entries(@user.id, @test_import)
    end
  end

  test "adding a new item to an existing category should work" do
    @importer.import_item_categories(@user.id, @single_import)

    assert_difference("@user.categories.size", 1) do
      assert_difference("@user.items.size", 1) do
        @importer.import_item_categories(@user.id, @test_import)
      end
    end
  end

  test "lines with an empty item name are ignored" do
    line_with_no_item = @tricky_line_parsed
    line_with_no_item.delete "name"

    result = @importer.handle_line line_with_no_item
    assert_nil result

    merged = @importer.merge(result, [])
    assert_empty merged

    assert_no_difference("User.find(@user.id).items.count") do
      @importer.import_item_categories @user.id, merged
    end

    assert_no_difference("User.find(@user.id).entries.count") do
      @importer.import_entries @user.id, merged
    end
  end

  test "importing an item with the same name as an existing item is handled" do
    @importer.import_item_categories(@user.id, @tricky_import)
    Item.where(name: @tricky_import.first[:name]).first.destroy

    assert_no_difference("@user.categories.count") do
      assert_difference("@user.items.count", 1) do
        @importer.import_item_categories(@user.id, @tricky_import)
      end
    end

    imported_items = Item.where(name: @tricky_import.first[:name]).order(:id)
    assert_equal @tricky_import.size, imported_items.size
    assert_not_equal imported_items.first.id, imported_items.last.id
    assert_not_equal imported_items.first.category_ids, imported_items.last.category_ids

    if imported_items.first.categories.pluck(:name).first.eql? @tricky_import.first[:categories].first
      assert_equal @tricky_import.last[:categories].first, imported_items.last.categories.pluck(:name).first
    end
  end
  
  test "new CSV format is imported" do
    line_one = @importer.handle_line @test_line_one
    line_two = @importer.handle_line @test_line_two
    line_three = @importer.handle_line @test_line_three
    
    new_line_one = @importer.handle_line @new_format_line_one
    new_line_two = @importer.handle_line @new_format_line_two
    new_line_three = @importer.handle_line @new_format_line_three
    
    assert_equal line_one, new_line_one
    
  end
end
