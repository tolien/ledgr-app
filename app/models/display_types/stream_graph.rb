class DisplayTypes::StreamGraph < DisplayType

  def get_data_for(display)
    data = super(display)
    #    data = data.select("items.id, items.name, entries.quantity AS sum")
    #    data = data.group(:id, :name)

    unless data.empty?
      
#      unless ActiveRecord::ConnectionAdapters.constants.include? :PostgreSQLAdapter and ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        
        data = data.reorder('entries.datetime ASC')
        data = data.pluck('items.id, items.name, entries.quantity AS sum, entries.datetime')    
        
        if display.start_date.nil?
          min_date = data.first[3]
        else
          min_date = display.start_date
        end
  
        max_date = DateTime.now
  
        Rails.logger.debug("min date: #{min_date} max date: #{max_date}")
        
        days = ((max_date.to_datetime.at_beginning_of_day - min_date.to_datetime.at_beginning_of_day) / 10)
        
        Rails.logger.debug("Days per interval: #{days}")
        data = data.map do |item|
          item = { 
            item_id: item[0],
            name: item[1],
            value: item[2],
            date: date_trunc(days * 24, item[3].to_datetime)
          }
        end

        result = []
        data = data.group_by {|i| i[:date]}
        
        data.each do |date, date_row|
          if date < display.start_date
            next
          end
          date_row = date_row.group_by { |i| i[:item_id] }
          date_row.each do |item_id, items|
            result << {
              item_id: item_id,
              name: items.first[:name],
              value: items.inject(0) { |sum,n| sum + n[:value]},
              date: date
            }
          end
        end
        result
#      else
#        data = data.reorder('date ASC')
#        data = data.group("items.id, items.name, date")
#        data = data.pluck("items.id, items.name, sum(entries.quantity) AS sum, date_trunc('month', entries.datetime) AS date")
#        data = data.map do |item|
#          item = { item_id: item[0], name: item[1], value: item[2], date: item[3].to_datetime}
#        end
        
#        data # = data.group_by { |i| i[:date]}
#      end
    end
    
  end
  
  def date_trunc(hours, date)
    epoch = Time.at(0)
    hours_since_epoch = ((date.to_time - epoch) / 1.hour)
    intervals = (hours_since_epoch / hours).floor
    new_date = epoch + (intervals * hours).hours
    new_date
  end
  
end
