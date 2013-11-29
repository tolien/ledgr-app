class AddPreviousAndNextIdsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :previous_id, :integer
    add_column :pages, :next_id, :integer
    
    add_foreign_key :pages, :pages, column: "previous_id"
    add_foreign_key :pages, :pages, column: "next_id"
  end
end
