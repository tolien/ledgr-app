class CreateDisplays < ActiveRecord::Migration[5.0]
  def change
    create_table :displays do |t|
      t.text :title
      t.datetime :start_date
      t.datetime :end_date
      t.integer :display_type_id, null: false

      t.timestamps null: :false
    end
  end
end
