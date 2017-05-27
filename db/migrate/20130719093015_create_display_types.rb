class CreateDisplayTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :display_types do |t|
      t.text :name
      t.text :description
      t.text :type

      t.timestamps null: :false
    end
  end
end
