class DisplayTypes::PieChart < DisplayType

  def get_data_for(display)
    data = super(display)
    data = data.group(:name)
    data = data.reorder('sum DESC')
    
    data
  end
end
