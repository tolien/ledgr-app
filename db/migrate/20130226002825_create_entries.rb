class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.decimal :quantity
      t.datetime :datetime

      t.timestamps null: :false
    end
  end
end
