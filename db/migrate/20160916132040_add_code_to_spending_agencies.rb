class AddCodeToSpendingAgencies < ActiveRecord::Migration[5.0]
  def change
    add_column :spending_agencies, :code, :string
  end
end
