class RemoveEndDateFromNames < ActiveRecord::Migration[5.0]
  def up
    remove_column :names, :end_date
  end

  def down
    add_column :names,
               :end_date,
               :date,
               index: true
  end
end
