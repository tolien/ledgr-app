class DisplayTypes::PieChart < DisplayType
  def get_data_for(display)
    data = super(display)
    data = data.select("items.id, items.name, sum(entries.quantity) AS sum")
    data = data.group(:id, :name)

    unless data.empty?
      data = data.reorder("sum DESC")
    end

    data.to_a
  end
end
