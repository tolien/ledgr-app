require 'test_helper'

class TimeSinceLastEntryTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, user: @user)
    display_type = DisplayTypes::TimeSinceLastEntry.new
    display_type.name = 'blah'
    display_type.save!
    @display = FactoryGirl.create(:display, display_type: display_type, page: @page)
    @category1 = FactoryGirl.create(:category, user: @user)
    @category2 = FactoryGirl.create(:category, user: @user)
  end
  
  test "the truth" do
    
  end
end
