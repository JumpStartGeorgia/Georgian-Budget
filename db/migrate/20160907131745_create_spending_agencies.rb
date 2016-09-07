class CreateSpendingAgencies < ActiveRecord::Migration[5.0]
  def change
    create_table :spending_agencies do |t|
      t.timestamps
    end
  end
end
