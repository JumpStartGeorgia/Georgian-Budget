class AddTimePeriodToFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :spent_finances, :time_period, :string, index: true
    add_column :planned_finances, :time_period, :string, index: true
  end
end
