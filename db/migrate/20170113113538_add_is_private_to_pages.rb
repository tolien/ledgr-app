class AddIsPrivateToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :is_private, :boolean, default: false
  end
end
