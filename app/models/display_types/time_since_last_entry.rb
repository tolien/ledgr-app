class DisplayTypes::TimeSinceLastEntry < DisplayType
  
  def get_data_for(display)
    data = super(display)
    max_date = data.maximum("entries.datetime")
    unless max_date.nil? or max_date.empty?
      Time.parse(max_date)
    end
  end
end
