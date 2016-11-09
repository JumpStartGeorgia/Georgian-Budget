class AddStartDateToBudgetItems < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :start_date, :date, index: true
    add_column :spending_agencies, :start_date, :date, index: true
    add_column :priorities, :start_date, :date, index: true
    add_column :totals, :start_date, :date, index: true
  end
end
