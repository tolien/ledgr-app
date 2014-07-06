class Importer < Object
  
  def merge(to_merge, merge_into)
    key = to_merge.name
    unless merge_into.include? key
      merge_into[key] = [ to_merge ]
    else
      merge_into[key] << to_merge
    end
    merge_into
  end
  
  def handle_line(row)
    item_name = row['name'].strip
    categories = row['categories'].split(';')
    quantity = row['amount'].to_f
    datetime = row['date'].to_datetime
    
    result = {
      name: item_name,
      quantity: quantity,
      categories: categories,
      datetime:datetime
    }
    
    result
  end
  
  def import_item_categories(user_id, item_categories)
    items_to_insert = []
    categories_to_insert = []
    unless user_id.nil? or item_categories.nil?
      item_categories.each do |entry|
        prototype_item = Item.new(user_id: user_id, name: entry[:name])      
        entry[:categories].each do |category|
          Rails.logger.debug("Importing category " + category)
          categories_to_insert.each do |seen_category|
            if seen_category.name == category
              Rails.logger.debug("Not creating duplicate category: " + category)
              category = nil
            end
          end
          unless category.nil?
            prototype_category = Category.new(user_id: user_id, name: category)
            prototype_item.categories << prototype_category
            categories_to_insert << prototype_category
          end
        end
        items_to_insert << prototype_item
      end
    end
    
    Item.import items_to_insert
    Category.import categories_to_insert    
  end
  
  def import(file, user)
    # store some structure of imported items, their categories and entries
    to_import = {}
    # iterate over the file, turning every line into a Map
    # header column name -> row value
    CSV.foreach(file, headers: :true) do |row|
      # turn the map into some kind of object representation
      row_object = handle_line(row)
      # merge with the maps for the other rows
      # (i.e. if we've already seen that item, add the new entry to it, otherwise create a new item to store it)
      merge row_object to_import
    end
    
    # iterate over the imported items, turning them into Items and persisting them in one go
  end
end
