class ChangeLegacyPksToBigint < ActiveRecord::Migration[5.2]
  def up
    unless ActiveRecord::Base.connection.adapter_name == 'SQLite'
      change_column :items, :id, :bigint
      change_column :users, :id, :bigint
      change_column :entries, :id, :bigint
      change_column :categories, :id, :bigint
      change_column :pages, :id, :bigint
      change_column :displays, :id, :bigint
      change_column :display_types, :id, :bigint
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
  def down
    unless ActiveRecord::Base.connection.adapter_name == 'SQLite'
      change_column :items, :id, :int
      change_column :users, :id, :int
      change_column :entries, :id, :int
      change_column :categories, :id, :int
      change_column :pages, :id, :int
      change_column :displays, :id, :int
      change_column :display_types, :id, :int
      change_column :categories, :user_id, :int
      change_column :display_categories, :category_id, :int
      change_column :display_categories, :display_id, :int
      change_column :displays, :display_type_id, :int
      change_column :displays, :page_id, :int
      change_column :entries, :item_id, :int
      change_column :entries, :item_id, :int
      change_column :item_categories, :item_id, :int
      change_column :item_categories, :category_id, :int
      change_column :items, :user_id, :int
      change_column :pages, :user_id, :int
    end
  end
end
