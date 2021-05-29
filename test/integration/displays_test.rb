require "test_helper"

class DisplaysTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = FactoryBot.create(:user)
    @category = FactoryBot.create(:category, user: @user)
    @page = FactoryBot.create(:page, user: @user)
    @display = FactoryBot.create(:display, start_date: nil, page: @page)
    @display.categories << @category
    @display.save!
  end
  
  test "displays work when there's no data" do
    @display.display_type = DisplayTypes::TimeSinceLastEntry.find_or_create_by(name: 'Time Since Last Entry')
    assert_not_nil @display.display_type
    @display.save
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 1
    assert_select "#display_#{@display.id} p.display_data", 0
    
    @display.display_type = DisplayTypes::AverageTimeBetweenEntry.find_or_create_by(name: 'Time Between Entries')
    assert_not_nil @display.display_type
    @display.save!
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_nil @display.get_data()
    assert_select "#display_#{@display.id} p.no_data", 1
    
    @display.display_type = DisplayTypes::DayAverage.find_or_create_by(name: 'Day Average')
    assert_not_nil @display.display_type
    @display.save!
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 1
    
    @display.display_type = DisplayTypes::Total.find_or_create_by(name: 'Total')
    assert_not_nil @display.display_type
    @display.save!
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 1
  end
  

  
  test "displays show useful things when there is data" do
    item = FactoryBot.create(:item)
    item.categories << @category
    item.save!
    rand(10).times do 
      entry = FactoryBot.create(:entry, item: item)
    end
    @display.display_type = DisplayTypes::TimeSinceLastEntry.find_or_create_by(name: 'Time Since Last Entry')
    assert_not_nil @display.display_type
    @display.save
    
    assert_not_nil @display.get_data()
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 0
    
    @display.display_type = DisplayTypes::AverageTimeBetweenEntry.find_or_create_by(name: 'Time Between Entries')
    assert_not_nil @display.display_type
    @display.save!
    assert_not_nil @display.get_data()
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 0
    
    @display.display_type = DisplayTypes::DayAverage.find_or_create_by(name: 'Day Average')
    assert_not_nil @display.display_type
    @display.save!
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_not_nil @display.get_data()
    assert_select "#display_#{@display.id} p.no_data", 0
    
    @display.display_type = DisplayTypes::Total.find_or_create_by(name: 'Total')
    assert_not_nil @display.display_type
    @display.save!
    
    get user_path(@user)
    assert_response :success
    assert_template "show"
    assert_select "#display_#{@display.id} p.no_data", 0
  end
end
