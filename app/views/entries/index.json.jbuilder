json.entries @entries do |entry|
  json.item_id entry.item.id  
  json.datetime entry.datetime
  json.quantity entry.quantity
end
