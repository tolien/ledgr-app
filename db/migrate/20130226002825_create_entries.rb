class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.decimal :quantity
      t.datetime :datetime

      t.timestamps
    end
  end
end
