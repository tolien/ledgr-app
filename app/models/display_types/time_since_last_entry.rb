class TimeSinceLastEntry < DisplayType
  
  def get_data_for(display)
    data = super(display)
    data.maximum("entries.datetime")
  end
end