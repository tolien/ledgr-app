class DisplayTypes::StreamGraph < DisplayType

  def get_data_for(display)
    data = super(display)
    #    data = data.select("items.id, items.name, entries.quantity AS sum")
    #    data = data.group(:id, :name)

    unless data.empty?
      
      unless ActiveRecord::ConnectionAdapters.constants.include? :PostgreSQLAdapter and ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        
        data = data.reorder('entries.datetime ASC')
        data = data.pluck('items.id, items.name, entries.quantity AS sum, entries.datetime')    

        data = data.map do |item|
          item = { item_id: item[0], name: item[1], value: item[2], date: date_trunc(:month, item[3].to_datetime)}
        end

        result = {}
        data = data.group_by {|i| i[:date]}
        data.each do |date, date_row|
          date_row = date_row.group_by { |i| i[:item_id] }
          date_row.each do |item_id, items|
            unless result.include? date
              result[date] = []
            end
            result[date] << {
              item_id: item_id,
              name: items.first[:name],
              value: items.inject(0) { |sum,n| sum + n[:value]}
            }
          end
          result[date].sort! {|x,y| y[:value] <=> x[:value]}
        end
        result
      else
        data = data.reorder('date ASC')
        data = data.group("items.id, items.name, date")
        data = data.pluck("items.id, items.name, sum(entries.quantity) AS sum, date_trunc('month', entries.datetime) AS date")
        data = data.map do |item|
          item = { item_id: item[0], name: item[1], value: item[2], date: date_trunc(:month, item[3].to_datetime)}
        end
        
      end
    end
    
  end
  
  def date_trunc(interval, date)
    unless date.nil?
      date = date.to_datetime
    end
    case interval
    when :day
      date = date.at_beginning_of_day
    when :month
      date = date.at_beginning_of_month
    when :year
      date = date.at_beginning_of_year
    end
    date
  end
end
