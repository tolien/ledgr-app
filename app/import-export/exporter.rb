class Exporter < Object
  def export(user_id)
    Rails.logger.info "Beginning export for user ID #{user_id}"
    start_time = Time.now

    user = User.find_by(id: user_id)

    unless user.nil?
      csv_string = ""
      csv_string << "name,date,amount,categories\n"

      item_map = {}

      Item.includes(:categories).where(user_id: user_id).each do |item|
        item_map[item.id] = item
      end

      Rails.logger.info "Finished mapping user's items/categories after #{Time.now - start_time} seconds"

      Entry
        .includes(:item)
        .where(items: { user_id: user_id })
        .reorder(datetime: :desc, created_at: :desc, id: :desc)
        .pluck(:item_id, :datetime, :quantity)
        .each do |entry|
        row = []

        item_id = entry[0]
        datetime = entry[1]
        quantity = entry[2]

        item = item_map[item_id]
        row << item.name
        row << datetime.utc.strftime("%a %b %d %T %Z %Y")
        row << quantity.to_f
        unless item.categories.empty?
          row << item.categories.pluck(:name).join("; ")
        end
        csv_string << row.to_csv
      end
      Rails.logger.info "Finished export after #{Time.now - start_time} seconds"
      csv_string
    end
  end
end
