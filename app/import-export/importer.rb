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
          Rails.logger.debug "Found a match for item #{item_name}"
          item_categories.each do |category|
            unless candidate_item[:categories].include? category
              Rails.logger.debug "Candidate item doesn't have category #{category} so creating a new item"
              merge_target = nil
              break
            else
              merge_target = candidate_item
            end
          end
          unless merge_target.nil?
            break
          end
        end
      end
      unless merge_target.nil?
        Rails.logger.debug "Merging entries"
        merge_target[:entries].push to_merge[:entries].first
      else
        Rails.logger.debug "No matching item found, inserting the item we were asked to merge"
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
    
    categories = categories.map { |category| category.strip }
    
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

  # the item-category association isn't saved by ActiveRecord-import
  # original solution was to iterate over items and call #save
  # but this made performance unacceptably slow (50-60x)
  # Solution AR-imports all of the items and categories separately
  # then iterate over each item in turn creating ItemCategories
  
  def import_item_categories(user_id, item_categories)
    items_to_insert = []
    categories_to_insert = {}
    unless user_id.nil? or item_categories.nil?
      item_categories.each do |item|
        Rails.logger.debug("Creating item #{item[:name]}")
        prototype_item = Item.new(user_id: user_id, name: item[:name])
        item[:categories].each do |category|
          Rails.logger.debug("Item has category " + category)
          if categories_to_insert.has_key? category
            Rails.logger.debug("Not creating duplicate category " + category)
            seen_category = categories_to_insert[category]
          else
            prototype_category = Category.new(user_id: user_id, name: category)
            prototype_item.categories << prototype_category
            categories_to_insert[category] = prototype_category
          end
        end
        items_to_insert << prototype_item
      end
      
      Item.import items_to_insert, validate: false
      Category.import categories_to_insert.values, validate: false
    
      itemcategories_to_insert = []
      available_items = {}
      item_categories.each do |item|
        unless available_items.has_key? item[:name]
          item_id_list = Item.where(name: item[:name], user_id: user_id).includes(:item_categories).where(item_categories: { item_id: nil } ).pluck(:id)
          available_items[item[:name]] = item_id_list
          item_id = item_id_list.pop
        else
          item_id_list = available_items[item[:name]]
          item_id = item_id_list.pop
        end
        unless item[:categories].nil? or item[:categories].empty?
          unless item_id.nil?
            item[:categories].each do |category_name|
              category_id = Category.where(user_id: user_id, name: category_name).pluck(:id).first
              prototype_itemcategory = ItemCategory.new
              prototype_itemcategory.item_id = item_id
              prototype_itemcategory.category_id = category_id
              itemcategories_to_insert << prototype_itemcategory
            end
          else
            Rails.logger.debug "Found no item IDs for item '#{item[:name]}'"
          end         
        else
          Rails.logger.debug "Item #{item[:name]} has no categories"
        end
      end
      ItemCategory.import itemcategories_to_insert, validate: false
  
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
  end
end
