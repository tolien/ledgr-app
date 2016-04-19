class AddDisplayFks < ActiveRecord::Migration
  def change
    add_foreign_key "display_categories", "categories", :name => "display_categories_category_id_fk", dependent: :delete
    add_foreign_key "display_categories", "displays", :name => "display_categories_display_id_fk", dependent: :delete
    add_foreign_key "displays", "display_types", :name => "displays_display_type_id_fk", dependent: :delete
  end
end
