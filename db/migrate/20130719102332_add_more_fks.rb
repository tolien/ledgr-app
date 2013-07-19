class AddMoreFks < ActiveRecord::Migration
  def change
    add_foreign_key "display_categories", "categories", :name => "display_categories_category_id_fk"
    add_foreign_key "display_categories", "displays", :name => "display_categories_display_id_fk"
    add_foreign_key "displays", "display_types", :name => "displays_display_type_id_fk"
    add_foreign_key "item_categories", "categories", :name => "item_categories_category_id_fk"
    add_foreign_key "item_categories", "items", :name => "item_categories_item_id_fk"
  end
end
