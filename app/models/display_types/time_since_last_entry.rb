class DisplayTypes::TimeSinceLastEntry < DisplayType
  
  def get_data_for(display)
    data = super(display)
    max_date = data.maximum("entries.datetime")
    unless max_date.nil? or max_date.is_a? Time
      max_date = Time.parse(max_date)
    end
    max_date
  end
end
