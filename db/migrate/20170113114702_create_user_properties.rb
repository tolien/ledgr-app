class CreateUserProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :user_properties do |t|
      t.references :user, index: true, foreign_key: true
      t.boolean :is_private, default: false
    end
  end
end
