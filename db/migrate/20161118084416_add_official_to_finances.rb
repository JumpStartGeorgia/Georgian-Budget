class AddOfficialToFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :spent_finances,
               :official,
               :boolean,
               index: true,
               default: true,
               null: false

    add_column :planned_finances,
               :official,
               :boolean,
               index: true,
               default: true,
               null: false
  end
end
