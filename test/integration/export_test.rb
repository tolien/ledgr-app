require 'test_helper'
require 'fileutils'

class ExportTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = FactoryBot.create(:user)
    @item = FactoryBot.build(:item, user: @user)
    @entry = FactoryBot.build(:entry, item: @item)
    @exporter = Exporter.new
    @tempdir = Rails.root.join('tmp').join('testfiles')
    unless @tempdir.exist?
      FileUtils.mkdir_p @tempdir
    end
  end
  
  def teardown
    if @tempdir.exist?
      FileUtils.rm_rf @tempdir
    end
  end

  test "export returns only the header if the user has no entries" do
    @item.save
    
    csv = @exporter.export @user
    assert_not_nil csv
    assert_equal 1, csv.count("\n")
    assert csv.start_with? "name"
  end
  
  test "export returns all of user's entries" do
    10.times do
        item = FactoryBot.create(:item, user: @user)
        FactoryBot.create(:entry, item: item)
    end
    
    csv = @exporter.export @user
    assert_not_nil csv
    assert_equal 11, csv.count("\n")
  end
  
  test "assert that exporting then importing has no net result" do
    10.times do
        item = FactoryBot.create(:item, user: @user)
        SecureRandom.random_number(10).times do
          category = FactoryBot.create(:category, user: @user)
          item.categories << category
        end
        FactoryBot.create(:entry, item: item)
    end
    
    tempfile = @tempdir.join(SecureRandom.random_number(10).to_s)
    csv_string = @exporter.export @user
    File.write tempfile, csv_string
    
    import = Importer.new
    assert_no_difference '@user.categories.count' do
      assert_no_difference '@user.entries.count' do
        assert_no_difference '@user.items.count' do
          import.import tempfile, @user
        end
      end
    end
  end
  
end
