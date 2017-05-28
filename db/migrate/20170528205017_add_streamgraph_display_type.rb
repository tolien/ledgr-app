class AddStreamgraphDisplayType < ActiveRecord::Migration[5.1]
  def change
    display_type = DisplayTypes::StreamGraph.find_or_create_by(name: 'Streamgraph')
    display_type.save!
  end
end
