class AddMostRecentlyAnnouncedToPlannedFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :planned_finances,
               :most_recently_announced,
               :boolean,
               index: true,
               default: false,
               null: false
  end
end
