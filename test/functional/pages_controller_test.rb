require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = FactoryGirl.create(:owned_page)
  end
  
  test "no index route" do
    assert_raises(ActionController::RoutingError) do
      assert_recognizes({}, '/#{@page.user.username}/pages')
    end
  end
end
