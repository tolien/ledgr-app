require 'csv'

module ApplicationHelper
  def get_datetime_format_string(show_date, show_time)
    if show_date.nil?
      show_date = true
    end
    
    if show_time.nil?
      show_time = true
    end
    
    string = ""
    if show_date
      string += Rails.application.config.date_format
      if show_time
        string += " "
      end
    end
    if show_time
      string += Rails.application.config.time_format
    end
    string
  end
end
