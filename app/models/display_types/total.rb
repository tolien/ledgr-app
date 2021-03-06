class DisplayTypes::Total < DisplayType
  def get_data_for(display)
    data = super(display)
    data = data.unscope(:select)
    data = data.unscope(:order)
    data = data.select("sum(entries.quantity) as entry_total")
    unless data.nil? or data.empty?
      data = data[0]
      count = data.entry_total
    end

    unless count.nil?
      count.to_f
    end
  end
end
