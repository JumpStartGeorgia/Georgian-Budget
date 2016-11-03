class AddTimePeriodTypeToSpentFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :spent_finances, :time_period_type, :string
    add_index :spent_finances, :time_period_type
  end
end
