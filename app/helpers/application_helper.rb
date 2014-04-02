require 'csv'

module ApplicationHelper
  def import_from_csv(filename, user_id)
    
    # this method reads a specified CSV file and loads all of the entries specified within,
    # creating items and categories where required and associating all three
    # for performance, the file is turned into a lists of strings
    # and objects mass-imported using ActiveRecord import
    
    start_time = Time.now
    
    user = User.find(user_id)
    Rails.logger.info("Found user with username #{user.username}")
    
    count = 0
    old_category_count = user.categories.size
    old_item_count = user.items.size
    old_entry_count = user.entries.size
    
    category_name_list = []
    item_name_list = []
    item_category_map = {}
    entry_name_list = []
    counter_map = {}
      
    # iterate over every row in the file
    CSV.foreach(filename, headers: :true) do |row|
      # load the item's name into the list of items to create
      item_name = row['name'].strip
      unless item_name_list.include? item_name
        item_name_list << item_name
      end
      
      # load the categories for this item
      categories = row['categories'].split(';')
      categories.each do |category_name|
        category_name = category_name.strip
        # if this category hasn't been encountered before, add its name
        unless category_name_list.include? category_name
#          Rails.logger.debug("Adding #{category_name} to the list of categories to create")
          category_name_list << category_name
        end
        
      # add the item-category mapping if it hasn't already been
        item_categories = item_category_map[item_name]
        if item_categories.nil?
          item_categories = []
        end
        unless item_categories.include? category_name
          item_categories << category_name
        end
        item_category_map[item_name] = item_categories
      end
      
      # put entries into a list-of-arrays
      # ready for mass import
      entry_name_list << [row['name'], row['amount'].to_f, row['date'].to_datetime]        
      
      unless counter_map.include? item_name
        counter_map[item_name] = 0
      end
      counter_map[item_name] = counter_map[item_name]+1
       
      count = count + 1
    end
    
    Rails.logger.debug("+#{get_seconds(start_time)}: Finished with the CSV file")
      
    Rails.logger.debug("Read #{category_name_list.size} unique category names")
    Rails.logger.debug("Read #{item_name_list.size} unique item names")
    
    # turn the list of category names into a list of Category objects
    category_list = []
    category_name_list.each do |category_name|
      category_list << Category.new(name: category_name, user_id: user.id)
    end
      
    # form a list of Item objects
    item_list = []
    item_name_list.each do |item_name|
      prototype_item = Item.new(name: item_name, user_id: user.id)
      prototype_item.entries_count = counter_map[item_name]
      item_list << prototype_item
    end
    
    # import all the categories and items created
    Item.transaction do      
      Category.import category_list, validate: false
      Item.import item_list, validate: false
    end
    
    Rails.logger.debug("+#{get_seconds(start_time)}: Categories and Items loaded")
    # then associate items with categories
    category_id_map = Category.where('user_id = ?', user.id).select([:name, :id]).reduce({}) { |hash,category| hash[category.name] = category; hash }
    item_category_data = []
      
    Item.where("user_id = ?", user.id).all.each do |item|
      #Rails.logger.debug("Loading categories for #{item.name}")
      item_name = item.name
      item_categories = item_category_map[item_name]
      if item_categories
        #Rails.logger.debug("There are #{item_categories.size} categories for this item.")
        item_categories.each do |category_name|
          category = category_id_map[category_name]
          #Rails.logger.debug("Adding category #{category_name} (ID #{category.id}) to #{item.name}")
          unless category.nil?
            item_category_data << [item.id, category.id]
          end
        end
      end
    end
    ItemCategory.transaction do
      columns = [:item_id, :category_id]
      ItemCategory.import columns, item_category_data, validate: false
    end
    
    Rails.logger.debug("+#{get_seconds(start_time)}: item-category associations loaded")
    
    
    Rails.logger.info("Loading entries")
    # now load entries
    entry_list = entry_name_list
    item_id_map = Item.where('user_id = ?', user.id).select([:name, :id]).reduce({}) { |hash,item| hash[item.name] = item.id; hash }
    entry_name_list.each do |entry_name|
      item_name = entry_name[0]
      item_id = item_id_map[item_name]
      
      #Rails.logger.debug("Creating entry with values user_id: #{user_id}, item_id: #{item_id}, quantity: #{entry_name[1]}, datetime: #{entry_name[2]}")
      entry_name[0] = item_id
    end
    
    Rails.logger.debug("+#{get_seconds(start_time)}: finished building list of entries for import")
    
#    Rails.logger.debug("Loading #{entry_list.size} entries.")

    entry_columns = [:item_id, :quantity, :datetime]
    Entry.transaction do
      entry_list.each_slice(500) do |slice|
        result = Entry.import entry_columns, slice, validate: false
        unless result.failed_instances.empty?
          Rails.logger.info("Failed to load #{result.failed_instances.size} records.")
        end
        Rails.logger.debug("+#{get_seconds(start_time)}: entry slice loaded")
      end
    end
    
    category_count = user.categories.size
    item_count = user.items.size
    end_time = Time.now
    entry_count = user.entries.size
    time_taken = end_time - start_time
    
    Rails.logger.info("Imported #{count} rows.")
    Rails.logger.info("Created #{category_count - old_category_count} categories")
    Rails.logger.info("Created #{item_count - old_item_count} items")
    Rails.logger.info("Created #{entry_count - old_entry_count} entries")
    Rails.logger.info("#{time_taken} seconds (#{(count / time_taken).round(0)} items/second).")
    
  end
  
  def get_seconds(start_time)
    Time.now - start_time
  end
  
  def import_item_categories(user, item_categories)
    items_to_insert = []
    categories_to_insert = []
    unless user.nil? or item_categories.nil?
      item_categories.each do |entry|
        items_to_insert << Item.new(user_id: user.id, name: entry[:name])
        entry[:categories].each do |category|
          Rails.logger.debug("Importing category " + category)
          categories_to_insert.each do |seen_category|
            if seen_category.name == category
              Rails.logger.debug("Not creating duplicate category: " + category)
              category = nil
            end
          end
          unless category.nil?
            prototype_category = Category.new(user_id: user.id, name: category)
            categories_to_insert << prototype_category
          end
        end
      end
    end
    
    Item.import items_to_insert
    Category.import categories_to_insert
  end
end
