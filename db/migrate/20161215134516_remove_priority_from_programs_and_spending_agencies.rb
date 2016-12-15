class RemovePriorityFromProgramsAndSpendingAgencies < ActiveRecord::Migration[5.0]
  def change
    remove_reference :spending_agencies, :priority, index: true, foreign_key: true
    remove_reference :programs, :priority, index: true, foreign_key: true
  end
end
