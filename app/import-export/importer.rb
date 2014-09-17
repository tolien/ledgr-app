require 'csv'

class Importer < Object
  
  # merge the objects falling out of handle_line
  # checking that the name and category lists match
  def merge(to_merge, merge_into)
    unless to_merge.nil?
      to_merge = to_merge.clone
      unless to_merge[:entries].nil?
        to_merge[:entries] = to_merge[:entries].clone
      end
    end
    unless merge_into.is_a? Array
      nil
    else
      item_name = to_merge[:name]
      item_categories = to_merge[:categories]
      merge_target = nil
      merge_into.each do |candidate_item|
        if candidate_item[:name].eql? item_name
          item_categories.each do |category|
            unless candidate_item[:categories].include? category
              merge_target = nil
            else
              merge_target = candidate_item
            end
          end
        end
      end
      unless merge_target.nil?
        merge_target[:entries].push to_merge[:entries].first
      else
        merge_into.push to_merge
      end
      merge_into
    end
  end
  
  def handle_line(row)
    item_name = row['name'].strip
    categories = row['categories'].split(';')
    quantity = row['amount'].to_f
    datetime = row['date'].to_datetime
    
    # this resembles an Item object
    # the item's name, a list of Categories and a list of Entries
    
    result = {
      name: item_name,
      categories: categories,
      entries: [
        {
          quantity: quantity,
          datetime:datetime
        }
      ]
    }
    
    result
  end
  
  def import_item_categories(user_id, item_categories)
    items_to_insert = []
    categories_to_insert = []
    unless user_id.nil? or item_categories.nil?
      item_categories.each do |item|
        prototype_item = Item.new(user_id: user_id, name: item[:name])
        item[:categories].each do |category|
          Rails.logger.debug("Item has category " + category)
          categories_to_insert.each do |seen_category|
            if seen_category.name == category
              Rails.logger.debug("Not creating duplicate category " + category)
              prototype_item.categories << seen_category
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
      
      items_to_insert.map do |item|
        item.save!
      end
    end
  end
  
  def import_entries(user_id, item_list)
    entries_to_insert = []
    item_list.each do |item|
      item_id_relation = Item.where('user_id = ? AND name = ?', user_id, item[:name])
      if item_id_relation.size == 1
        item_id = item_id_relation.first.id
      else
        item_id_relation.each do |candidate_item|
          if candidate_item.categories.where('name IN (?)', item[:categories])
            item_id = candidate_item.id
            break
          else
            item_id = nil
          end
        end
      end
      unless item[:entries].nil?
        item[:entries].each do |entry|
          prototype_entry = Entry.new
          prototype_entry.item_id = item_id
          prototype_entry.quantity = entry[:quantity]
          prototype_entry.datetime = entry[:datetime]
          entries_to_insert << prototype_entry
        end
      end
    end
    Entry.import entries_to_insert
  end
  
  def import(file, user)
    # store some structure of imported items, their categories and entries
    to_import = []
    # iterate over the file, turning every line into a Map
    # header column name -> row value
    CSV.foreach(file, headers: :true) do |row|
      # turn the map into some kind of object representation
      row_object = handle_line(row)
      # merge with the maps for the other rows
      # (i.e. if we've already seen that item, add the new entry to it, otherwise create a new item to store it)
      merge row_object, to_import
    end
    
    import_item_categories(user.id, to_import)
    import_entries(user.id, to_import)
    # iterate over the imported items, turning them into Items and persisting them in one go
    Rails.logger.debug("Importing #{to_import.count} items")
    to_import.each do |item|
      Rails.logger.debug("#{item.name}")
    end
  end
end
