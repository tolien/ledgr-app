class Exporter < Object
  def get_entries_for_export(user)
    items = Item.where(user: user)
  end
  
  def get_entries_for_export(user)
    entries = Entry.includes(:item).where(items: { user: user })
  end
  
  def export(user_id)
    user = User.find(user_id)
    
    unless user.nil?
      csv_string = CSV.generate do |csv|
        row = []
        Entry.includes(item: [:categories]).where(items: { user_id: user_id }).find_each do |entry|
          row << entry.item.name
          row << entry.datetime.utc
          row << entry.quantity.to_f
          unless entry.item.categories.empty?
            row << entry.item.categories.pluck(:name).join(',')
          end
        end
        csv << row
      end
      csv_string
    end  
  end
end
