class DisplayTypes::PieChart < DisplayType

  def get_data_for(display)
    data = super(display)
    data.group(:name)
    data.reorder('sum DESC')
  end
end
