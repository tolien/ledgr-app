class DisplayTypes::StreamGraph < DisplayType
  @@default_top_items_limit = 8

  def get_data_for(display)
    data = orig_data = super(display)
    
    unless data.empty?
        data = data.reorder('entries.datetime ASC')
        data = data.pluck(Arel.sql('items.id, items.name, entries.quantity AS sum, entries.datetime'))
        
        if display.start_date.nil?
          min_date = data.first[3].to_time
        else
          min_date = display.start_date
        end
  
        max_date = DateTime.now
  
#        Rails.logger.debug("min date: #{min_date} max date: #{max_date}")
        
        days = ((max_date.to_datetime.at_beginning_of_day - min_date.to_datetime.at_beginning_of_day) / 10)
        unless days > 0
          days = 1
        end
        
#        Rails.logger.debug("Days per interval: #{days}")
        data = data.map do |item|
          { 
            item_id: item[0],
            name: item[1],
            value: item[2],
            date: date_trunc(min_date, days * 24, item[3].to_datetime)
          }
        end

        result = []
        data = data.group_by {|i| i[:date]}
        
        data.each do |date, date_row|
          date_row = date_row.group_by { |i| i[:item_id] }
          date_row.each do |item_id, items|
            thing = {
              item_id: item_id,
              name: items.first[:name],
              value: items.inject(0) { |sum,n| sum + n[:value]},
              date: date
            }
            result << thing
          end
        end
        {data: result, top_items: get_top_items(orig_data)}
    end
    
  end
  
  def date_trunc(start_date, hours, date)
    epoch = start_date
    now_interval = (((Time.now - epoch) / 1.hour) / hours).floor
    
    hours_since_epoch = ((date.to_time - epoch) / 1.hour)
#    Rails.logger.debug("#{hours_since_epoch} hours")
    intervals = (hours_since_epoch / hours)
    remainder = intervals - intervals.floor
    intervals = intervals.floor
    
    # if the rounded date is greater than current time by 10% of the rounding interval
    # then round the date backwards one interval
    if hours > 12 and (intervals > 1 and remainder >= 0 and remainder < 0.1)
      intervals = intervals - 1
    end
    if intervals > now_interval
      intervals = now_interval
    end
#    Rails.logger.debug("#{intervals} intervals")
    epoch + (intervals * hours).hours
  end

  def get_top_items(orig_data, max_items=nil)

    if max_items.nil?
      max_items = @@default_top_items_limit
    end
    data = orig_data
    data = data.select("items.id, items.name, sum(entries.quantity) AS sum")
    data = data.group(:id, :name)
    data = data.limit(max_items)

    unless data.empty?
       data = data.reorder('sum DESC')
    end
    data    
  end
  
end
