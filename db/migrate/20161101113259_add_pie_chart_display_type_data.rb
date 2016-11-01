class AddPieChartDisplayTypeData < ActiveRecord::Migration[5.0]
  def change
    pie_chart_display_type = DisplayTypes::PieChart.create(name: 'Pie Chart')
    pie_chart_display_type.save!
  end
end
