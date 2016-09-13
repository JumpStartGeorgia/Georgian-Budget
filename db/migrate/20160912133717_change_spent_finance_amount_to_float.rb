class ChangeSpentFinanceAmountToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :spent_finances, :amount, :decimal, precision: 14, scale: 2
  end
end
