json.entries @items do |item|
  json.item_id item.id 
  json.name item.name
  json.categories item.categories do |category|
    json.category_id category.id
    json.name category.name
  end
end
