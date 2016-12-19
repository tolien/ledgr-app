class ChangeEntryQuantityScale < ActiveRecord::Migration[5.0]
  def change
    change_column :entries, :quantity, :decimal, precision: 14, scale: 4
  end
end
