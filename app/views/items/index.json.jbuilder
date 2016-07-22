json.cache! @items do
    json.array! @items, partial: 'items/item', as: :item
end
