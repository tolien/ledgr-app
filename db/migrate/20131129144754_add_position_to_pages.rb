class AddPositionToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :position, :integer, default: 0
  end
end
