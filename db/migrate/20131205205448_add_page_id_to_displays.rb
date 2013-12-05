class AddPageIdToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :page_id, :integer
  end
end
