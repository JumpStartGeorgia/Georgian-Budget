class AddPermaIdToBudgetItems < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :perma_id, :string, index: true
    add_column :spending_agencies, :perma_id, :string, index: true
    add_column :priorities, :perma_id, :string, index: true
    add_column :totals, :perma_id, :string, index: true
  end
end
