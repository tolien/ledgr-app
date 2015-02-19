require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  setup do
    @date_string = Rails.application.config.date_format
    @time_string = Rails.application.config.time_format
    @datetime_string = @date_string + ' ' + @time_string
  end
  
  test "should return the date format string" do
    result = get_datetime_format_string(true, false)
    assert_equal @date_string, result
  end
  
  test "should return the time format string" do
    result = get_datetime_format_string(false, true)
    assert_equal @time_string, result
  end
  
  test "should return the datetime format string" do
    result = get_datetime_format_string(true, true)
    assert_equal @datetime_string, result
  end
  
  test "should return nil" do
    result = get_datetime_format_string(false, false)
    assert_equal '', result
  end
end
