class AddPageIdToDisplays < ActiveRecord::Migration[5.0]
  def change
    add_column :displays, :page_id, :integer
  end
end
