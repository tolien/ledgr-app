require 'csv'

module ApplicationHelper
  def import_from_csv(filename, user_id)
    start_time = Time.now
    
    user = User.find(user_id)
    Rails.logger.info("Found user with username #{user.username}")
    count = 0
    old_category_count = Category.where("user_id = #{user_id}").count
    old_item_count = Item.where("user_id = #{user_id}").count
    Item.transaction do
      CSV.foreach(filename, headers: :true) do |row|
        new_entry = Entry.new
        new_entry.datetime = row['date'].to_datetime
        new_entry.quantity = row['amount'].to_f
        new_entry.user_id = user.id
        item = Item.find_or_create_by_user_and_name(user, row['name'])
        new_entry.item_id = item.id
        
        categories = row['categories'].split(';')
        categories.each do |category_name|
          category_name = category_name.strip
          category = Category.find_or_create_by_user_and_name(user, category_name)
          if !item.categories.include? category
            item.add_category(category)
          end
        end
              
        new_entry.save!
        count = count + 1
      end
    end
    
    category_count = Category.where("user_id = #{user_id}").count
    item_count = Item.where("user_id = #{user_id}").count
    end_time = Time.now
    time_taken = end_time - start_time
    
    Rails.logger.info("Imported #{count} rows.")
    Rails.logger.info("Created #{category_count - old_category_count} categories")
    Rails.logger.info("Created #{item_count - old_item_count} items")
    Rails.logger.info("#{(time_taken / 60).round(2)} minutes (#{count / time_taken} items/second).")
    
  end
end
