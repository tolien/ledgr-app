class ConvertIntegerFksToBigints < ActiveRecord::Migration[5.2]
  def change
    change_column :categories, :user_id, :bigint
    change_column :display_categories, :category_id, :bigint
    change_column :display_categories, :display_id, :bigint
    change_column :displays, :display_type_id, :bigint
    change_column :displays, :page_id, :bigint
    change_column :entries, :item_id, :bigint
    change_column :entries, :item_id, :bigint
    change_column :item_categories, :item_id, :bigint
    change_column :item_categories, :category_id, :bigint
    change_column :items, :user_id, :bigint
    change_column :pages, :user_id, :bigint
  end
end
