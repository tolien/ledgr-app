class DisplayTypes::StreamGraph < DisplayType
  @@default_top_items_limit = 8

  def get_data_for(display)
    data = orig_data = super(display)

    unless data.empty?
      data = data.reorder("entries.datetime ASC")
      data = data.pluck(Arel.sql("items.id, items.name, entries.quantity AS sum, entries.datetime"))

      if display.start_date.nil?
        min_date = data.first[3].to_time
      else
        min_date = display.start_date
      end

      if display.end_date.nil?
        max_date = DateTime.now.at_end_of_day
      else
        max_date = display.end_date
      end

      interval_count = 10
      days = ((max_date.to_datetime.at_end_of_day - min_date.to_datetime.at_beginning_of_day) / interval_count)
      unless days > 0
        days = 1
      end

      data = data.map do |item|
        {
          item_id: item[0],
          name: item[1],
          value: item[2],
          date: date_trunc(min_date, days * 24, item[3].to_datetime),
        }
      end

      result = []
      data = data.group_by { |i| i[:date] }

      data.each do |date, date_row|
        date_row = date_row.group_by { |i| i[:item_id] }
        date_row.each do |item_id, items|
          thing = {
            item_id: item_id,
            name: items.first[:name],
            value: items.inject(0) { |sum, n| sum + n[:value] },
            date: date,
          }
          result << thing
        end
      end
      { data: result, top_items: get_top_items(orig_data) }
    end
  end

  # this started off doing weird things with rounding
  # and was reimplemented as a while loop
  # but for a sufficiently small value of hours, this loop could take *millions* of iterations

  def date_trunc(start_date, hours, date)
    if date > DateTime.now
      date = DateTime.now
    end
    dd_days = (date.to_datetime - start_date.to_datetime).days
    intervals = dd_days / hours.hours
    intervals = intervals.floor - 1
    start_date = start_date + (intervals * hours).hours
    next_bin = start_date + hours.hours
    if next_bin < DateTime.now and ((DateTime.now - next_bin.to_datetime) / (hours.hours / 1.0.days)) >= 0.1
      start_date = next_bin
    end
    start_date
  end

  def get_top_items(orig_data, max_items = nil)
    if max_items.nil?
      max_items = @@default_top_items_limit
    end
    data = orig_data
    data = data.select("items.id, items.name, sum(entries.quantity) AS sum")
    data = data.group(:id, :name)
    data = data.limit(max_items)

    unless data.empty?
      data = data.reorder("sum DESC")
    end
    data
  end
end
