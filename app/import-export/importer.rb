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
      unless merge_into.is_a? Array
        nil
      else
        item_name = to_merge[:name]
        item_categories = to_merge[:categories]
        merge_target = nil
        # Rails.logger.debug "Merge source has categories #{item_categories}"
        merge_into.each do |candidate_item|
          if candidate_item[:name].eql? item_name
            # Rails.logger.debug "Found a match for item #{item_name}"
            # Rails.logger.debug "Candidate Item has categories #{candidate_item[:categories]}"
            item_categories.each do |category|
              unless candidate_item[:categories].include? category
                # Rails.logger.debug "Candidate item doesn't have category #{category} so creating a new item"
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
          # Rails.logger.debug "Merging entries"
          merge_target[:entries].push to_merge[:entries].first
        else
          # Rails.logger.debug "No matching item found, inserting the item we were asked to merge"
          merge_into.push to_merge
        end
        merge_into
      end
    else
      merge_into
    end
  end
  
  def handle_line(row)
    item_name = row['name']
    
    unless item_name.nil? or item_name.empty?
      item_name = item_name.strip
    else
      return nil
    end
    
    unless row['categories'].nil? or row['categories'].empty?
      categories = row['categories'].split(';')
    else
      categories = []
    end
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
	
def associate_items_and_categories(user_id, item_categories, existing_items)
  itemcategories_to_insert = []
  available_items = {}
  category_id_map = {}
  Rails.logger.debug "Entering associate_items_and_categories"

  item_categories.each do |item|
    # Rails.logger.debug "Item #{item[:name]}, categories #{item[:categories]} "
    
    unless item[:categories].empty?
#      Rails.logger.debug "Looking for an item with categories #{item[:categories]}"
      candidates = existing_items[item[:name]]
      existing_item_id = nil
      unless candidates.nil?
        candidates.each do |candidate|
          unless existing_item_id.nil?
            break
          end
          item[:categories].each do |category|
            unless candidate[:categories].include? category
#              Rails.logger.debug "Item doesn't match"
              existing_item_id = nil
              break
            else
#              Rails.logger.debug "Found matching item with ID #{candidate[:id]} and categories #{candidate[:categories]}"
              existing_item_id = candidate[:id]
            end
          end
        end
      end
      unless existing_item_id.nil?
#        Rails.logger.debug "Found item #{existing_item_id} which has name #{item[:name]} and categories #{item[:categories]} so not trying to tie these up"
        next
      end
    end

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
          unless category_id_map.has_key? category_name
            category_id = Category.where(user_id: user_id, name: category_name).pluck(:id).first
            category_id_map[category_name] = category_id
          else
            category_id = category_id_map[category_name]
          end
          prototype_itemcategory = ItemCategory.new
          prototype_itemcategory.item_id = item_id
          prototype_itemcategory.category_id = category_id
          itemcategories_to_insert << prototype_itemcategory
        end
      else
        # Rails.logger.debug "Found no item IDs for item '#{item[:name]}'"
      end
    else
      # Rails.logger.debug "Item #{item[:name]} has no categories"
    end
  end
  Rails.logger.debug "Importing #{itemcategories_to_insert.size} item-category associations"
  ItemCategory.import itemcategories_to_insert, validate: false

end
  def fetch_all_items(user_id)
    all_items = Item.where(user_id: user_id)
      .includes(:categories)
      .unscope(:order)

    existing_items = {}
    all_items.each do |item|
      category_names = []
      item.categories.each do |cat|
        category_names << cat.name
      end
      tuple = { id: item.id, name: item.name, categories: category_names}
      if existing_items.include? item.name
        existing_items[item.name] << tuple
      else
        existing_items[item.name] = [tuple]
      end
    end
    existing_items
  end
  
  # the item-category association isn't saved by ActiveRecord-import
  # original solution was to iterate over items and call #save
  # but this made performance unacceptably slow (50-60x)
  # Solution AR-imports all of the items and categories separately
  # then iterate over each item in turn creating ItemCategories
  
  # this now also handles existing categories - if they exist
  # (i.e. there is a category with that name)  
  # the category will not be inserted
  
  def import_item_categories(user_id, item_categories)
    items_to_insert = []
    categories_to_insert = {}
    all_items = fetch_all_items user_id

    unless user_id.nil? or item_categories.nil?
      existing_categories = Category.where(user_id: user_id).pluck(:name)
      item_categories.each do |item|
        existing_items = all_items[item[:name]]
        create_item = true
        unless existing_items.nil? or existing_items.empty?
          existing_items.each do |existing_item|
            if (existing_item[:categories].sort <=> item[:categories].sort) == 0
              create_item = false
            end
          end
        end
        if create_item
          # Rails.logger.debug("Creating item #{item[:name]}")
          prototype_item = Item.new(user_id: user_id, name: item[:name])
          item[:categories].each do |category|
            # Rails.logger.debug("Item has category " + category)
            if categories_to_insert.has_key? category or existing_categories.include? category
              # Rails.logger.debug("Not creating duplicate category " + category)
              seen_category = categories_to_insert[category]
            else
              prototype_category = Category.new(user_id: user_id, name: category)
              prototype_item.categories << prototype_category
              categories_to_insert[category] = prototype_category
            end
          end
          unless prototype_item.nil?
            items_to_insert << prototype_item
          end
        end
      end
      
      Item.import items_to_insert, validate: false
      Category.import categories_to_insert.values, validate: false
    end
		
    associate_items_and_categories(user_id, item_categories, all_items)
		
  end
  
  def get_item_id(user_items, item_name, item_categories)
    item_id_relation = user_items.size.times.select{ |i| user_items[i][1] == item_name }
    if item_id_relation.size == 1
      item_id = user_items[item_id_relation.first][0]
    else
      item_id_relation.each do |candidate_item|
        unless Item.includes(:categories).where(id: user_items[candidate_item][0], categories: { name: item_categories }).reorder(id: :asc).empty?
          item_id = user_items[candidate_item][0]
          break
        else
          item_id = nil
        end
      end
      item_id
    end
  end  
  
  def import_entries(user_id, item_list)
    if item_list.nil? or item_list.empty?
      return
    end
    
    items_to_reset_counter = []
    entry_time = Time.now
    entries_to_insert = []
    user = User.find(user_id)
    user_has_entries = user.entries.size > 0
    user_items = user.items.pluck(:id, :name)
    
    user_entries = {}
    entry_list = user.entries.reorder("entries.datetime DESC, entries.quantity DESC").pluck(:item_id, :datetime)
    entry_list.each do |entry|
      if user_entries.include? entry[0]
        user_entries[entry[0]] << entry[1]
      else
        user_entries[entry[0]] = [entry[1]]
      end
    end
    
    item_list.each do |item|
      reset_counter_cache = false
      item_id = get_item_id(user_items, item[:name], item[:categories])
      unless item[:entries].nil? or item[:entries].empty? or item_id.nil?
#        Rails.logger.info "Found existing item ID #{item_id}"
        if user_has_entries
            existing_entries = user_entries[item_id]

#          Rails.logger.info "Found #{existing_entries.size} existing entries"
        end
        item[:entries].each do |entry|
          existing_entry = nil
          unless existing_entries.nil? or existing_entries.empty?
            # existing_entry = existing_entries.last
            existing_entry = existing_entries.to_a.bsearch{|e| e <=> entry[:datetime] }
          end
          if existing_entry.nil?
            prototype_entry = Entry.new
            prototype_entry.item_id = item_id
            prototype_entry.quantity = entry[:quantity]
            prototype_entry.datetime = entry[:datetime]
            entries_to_insert << prototype_entry
            reset_counter_cache = true
          end
        end
        if reset_counter_cache
            items_to_reset_counter << item_id
        end
      end
    end
    Rails.logger.info "Finished creating #{entries_to_insert.size} prototype entries after #{Time.now - entry_time} seconds"
    Entry.transaction do
      Entry.import entries_to_insert, validate: false
    end
    Rails.logger.info "Finished inserting prototype entries after #{Time.now - entry_time} seconds"
    Item.transaction do
      items_to_reset_counter.each do |item_id|
        Item.reset_counters item_id, :entries
      end        
    end
    Rails.logger.info "Finished updating entries counter_cache after #{Time.now - entry_time} seconds"

  end
  
  def import(file, user)
    # store some structure of imported items, their categories and entries
    to_import = []
    # iterate over the file, turning every line into a Map
    # header column name -> row value
    
    start_time = Time.now
    CSV.foreach(file, headers: :true) do |row|
      # turn the map into some kind of object representation
      row_object = handle_line(row)
      # merge with the maps for the other rows
      # (i.e. if we've already seen that item, add the new entry to it, otherwise create a new item to store it)
      merge row_object, to_import
    end
    Rails.logger.info "Finished CSV handling in #{Time.now - start_time} seconds"
    
    import_item_categories(user.id, to_import)
    Rails.logger.info "Finished items and categories after #{Time.now - start_time} seconds"
    import_entries(user.id, to_import)
    Rails.logger.info "Finished. Total time #{Time.now - start_time} seconds"
  end
end
