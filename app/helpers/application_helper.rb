require 'csv'

module ApplicationHelper
  def import_from_csv(filename, user_id)
    start_time = Time.now
    
    user = User.find(user_id)
    Rails.logger.info("Found user with username #{user.username}")
    count = 0
    old_category_count = Category.where("user_id = ?", user_id).count
    old_item_count = Item.where("user_id = ?", user_id).count
    old_entry_count = Entry.where("user_id = ?", user_id).count
    
    category_name_list = []
    item_name_list = []
    item_category_map = {}
    entry_name_list = []
      
    # iterate over every row in the file
    CSV.foreach(filename, headers: :true) do |row|
      # load the item's name into the list
      item_name = row['name'].strip
      if !item_name_list.include? item_name
        item_name_list << item_name
      end
      
      # load the categories for this row
      categories = row['categories'].split(';')
      categories.each do |category_name|
        category_name = category_name.strip
        # if this category hasn't been encountered before, add its name
        if !category_name_list.include? category_name
          category_name_list << category_name
        end
        
        # add this item-category mapping if it hasn't already been seen
        categories.each do |category_name|
          item_categories = item_category_map[item_name]
          if item_categories.nil?
            item_categories = []
          end
          if !item_categories.include? category_name
            item_categories << category_name
          end
          item_category_map[item_name] = item_categories
        end
      end
      
      # jam entries into a list-of-arrays
      # TODO: better way of doing this kthx      
      entry_name_list << [row['name'], row['amount'].to_f, row['date'].to_datetime]        
      
      count = count + 1
    end
      
    Rails.logger.debug("Read #{category_name_list.count} unique category names")
    Rails.logger.debug("Read #{item_name_list.count} unique item names")
    
    # turn the list of category names into a list of Category objects
    category_list = []
    category_name_list.each do |category_name|
      category_list << Category.new(name: category_name, user_id: user.id)
    end
      
    # form a list of Item objects
    item_list = []
    item_name_list.each do |item_name|
      item_list << Item.new(name: item_name, user_id: user.id)
    end
    
    # import all the categories and items created
    Item.transaction do      
      Category.import category_list
      Item.import item_list
      
      # then associate items with categories
      Item.where("user_id = ?", user.id).each do |item|
        Rails.logger.debug("Loading categories for #{item.name}")
        item_name = item.name
        item_categories = item_category_map[item_name]
        if item_categories
          Rails.logger.debug("There are #{item_categories.count} categories for this item.")
          item_categories.each do |category_name|
            category = Category.where("user_id = ? AND name = ?", user.id, category_name)
            Rails.logger.debug("Adding category #{category.name}")
            item.add_category(category)
          end
        end
      end
    end
    
    
    Rails.logger.info("Loading entries")
    # now load entries
    entry_list = []
    item_id_map = {}
    entry_name_list.each do |entry_name|
      item_name = entry_name[0]
      item_id = item_id_map[item_name]
      if item_id.nil?
        Rails.logger.debug("Haven't seen item with name #{item_name} before.")
        item_id = Item.find_by_name_and_user_id(item_name, user.id).id
        item_id_map[item_name] = item_id
      end
      #Rails.logger.debug("Creating entry with values user_id: #{user_id}, item_id: #{item_id}, quantity: #{entry_name[1]}, datetime: #{entry_name[2]}")
       entry_list << Entry.new(item_id: item_id, quantity: entry_name[1], datetime: entry_name[2])
    end
    
    Rails.logger.debug("Loading #{entry_list.count} entries.")
    Entry.transaction do
      entry_list.each_slice(500) do |slice|
        result = Entry.import slice, validate: :false
        if !result.failed_instances.empty?
          Rails.logger.info("Failed to load #{result.failed_instances.count} records.")
        end
      end
    end
        
    category_count = Category.where("user_id = ?", user_id).count
    item_count = Item.where("user_id = ?", user_id).count
    end_time = Time.now
    entry_count = Entry.where("user_id = ?", user_id).count
    time_taken = end_time - start_time
    
    Rails.logger.info("Imported #{count} rows.")
    Rails.logger.info("Created #{category_count - old_category_count} categories")
    Rails.logger.info("Created #{item_count - old_item_count} items")
    Rails.logger.info("Created #{entry_count - old_entry_count} entries")
    Rails.logger.info("#{time_taken} seconds (#{(count / time_taken).round(0)} items/second).")
    
  end
end
