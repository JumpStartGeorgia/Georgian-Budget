class RemoveCodeFromPriorities < ActiveRecord::Migration[5.0]
  def change
    remove_column :priorities, :code
  end
end
