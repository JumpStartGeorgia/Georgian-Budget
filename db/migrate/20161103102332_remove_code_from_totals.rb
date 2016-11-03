class RemoveCodeFromTotals < ActiveRecord::Migration[5.0]
  def change
    remove_column :totals, :code
  end
end
