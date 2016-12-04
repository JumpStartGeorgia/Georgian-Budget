class AddPrimaryToFinances < ActiveRecord::Migration[5.0]
  def change
    add_column :spent_finances, :primary, :boolean, index: true, default: false, null: false
    add_column :planned_finances, :primary, :boolean, index: true, default: false, null: false
  end
end
