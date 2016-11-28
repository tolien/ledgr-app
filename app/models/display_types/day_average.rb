class DisplayTypes::DayAverage < DisplayType

  def get_data_for(display)
    data = super(display)
    data = data.unscope(:select)
    data = data.unscope(:order)
    data = data.select("max(entries.datetime) as last_entry, min(entries.datetime) as first_entry, sum(entries.quantity) as entry_count")
    unless data.nil? or data.empty?
      data = data[0]
      count = data.entry_count
    end
    
    unless count.nil?
      max_date = data.last_entry.to_datetime
      min_date = data.first_entry.to_datetime
      date_delta = max_date.to_date - min_date.to_date
      if date_delta < 1
        date_delta = 1
      end
      delta = count / date_delta
      delta.to_f
    end
  end
end
