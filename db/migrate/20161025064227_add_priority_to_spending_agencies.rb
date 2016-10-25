class AddPriorityToSpendingAgencies < ActiveRecord::Migration[5.0]
  def change
    add_reference :spending_agencies, :priority, foreign_key: true, index: true
  end
end
