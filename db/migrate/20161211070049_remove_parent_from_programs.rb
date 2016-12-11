class RemoveParentFromPrograms < ActiveRecord::Migration[5.0]
  def change
    remove_column :programs, :parent_id
    remove_column :programs, :parent_type
  end
end
