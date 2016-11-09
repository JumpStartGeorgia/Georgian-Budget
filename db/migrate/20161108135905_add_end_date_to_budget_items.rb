class AddEndDateToBudgetItems < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :end_date, :date, index: true
    add_column :spending_agencies, :end_date, :date, index: true
    add_column :priorities, :end_date, :date, index: true
    add_column :totals, :end_date, :date, index: true
  end
end
