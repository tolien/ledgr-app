json.cache! @items do
    json.items @items, partial: 'items/item', as: :item
end
