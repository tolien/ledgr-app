class DisplayTypes::PieChart < DisplayType

  def get_data_for(display)
    data = super(display)
    data = data.select("items.id, items.name, sum(entries.quantity) AS sum")
    data = data.group(:id, :name)
    data = data.reorder('sum DESC')
    
    data
  end
end
