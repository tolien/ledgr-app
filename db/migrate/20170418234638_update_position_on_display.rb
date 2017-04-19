class UpdatePositionOnDisplay < ActiveRecord::Migration[5.0]
  def change
    Page.all.each do |page|
      page.displays.reorder(updated_at: :ASC).each.with_index(1) do |display, index|
        if display.position.nil?
          display.update_column :position, index
        end
      end
    end
  end
end
