class CreateDisplays < ActiveRecord::Migration
  def change
    create_table :displays do |t|
      t.text :title
      t.datetime :start_date
      t.datetime :end_date
      t.integer :display_type_id, null: false

      t.timestamps
    end
  end
end
