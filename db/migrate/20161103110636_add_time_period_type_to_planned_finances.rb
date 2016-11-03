class AddTimePeriodTypeToPlannedFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :planned_finances, :time_period_type, :string
    add_index :planned_finances, :time_period_type
  end
end
