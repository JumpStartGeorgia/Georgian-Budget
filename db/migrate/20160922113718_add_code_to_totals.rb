class AddCodeToTotals < ActiveRecord::Migration[5.0]
  def change
    add_column :totals, :code, :string
  end
end
