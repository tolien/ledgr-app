class DisplayTypes::EntriesPerDay < DisplayType

  def get_data_for(display)
    data = super(display)
    data = data.unscope(:select)
    data = data.unscope(:order)
    data = data.select("max(entries.datetime) as last_entry, min(entries.datetime) as first_entry, count(*) as entry_count")
    unless data.nil? or data.empty?
      data = data[0]
      count = data.entry_count
    end
    
    unless count.nil?
      if count < 2
        0
      else
        max_date = data.last_entry.to_datetime
        min_date = data.first_entry.to_datetime
        delta = count / (max_date.to_date - min_date.to_date)
        delta.to_f
      end
    end
  end
end
