json.entries @entries do |entry|
  json.item_id entry.item.id  
  json.item_name entry.item.name
  json.datetime entry.datetime
  json.quantity entry.quantity
end
