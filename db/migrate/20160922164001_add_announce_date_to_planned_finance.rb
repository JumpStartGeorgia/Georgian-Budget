class AddAnnounceDateToPlannedFinance < ActiveRecord::Migration[5.0]
  def change
    add_column :planned_finances, :announce_date, :date, index: true
  end
end
