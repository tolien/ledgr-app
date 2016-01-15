require 'test_helper'

class DisplayTypeTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @type = FactoryGirl.create(:display_type)
    @page = FactoryGirl.build(:page)
    @page.user = @user
    @page.save!
    
    5.times do
      display = FactoryGirl.build(:display)
      display.page = @page
      display.display_type = @type
      display.save!
    end    
        
  end
  
  test "destroying a display type destroys its dependent displays" do
    # assert that there are displays beforehand, or this test is pointless
    assert !Display.where('display_type_id = ?', @type.id).empty?
    @type.destroy
    assert Display.where('display_type_id = ?', @type.id).empty?
  end
end
