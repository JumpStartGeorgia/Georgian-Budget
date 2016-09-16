class AddCodeToPriorities < ActiveRecord::Migration[5.0]
  def change
    add_column :priorities, :code, :string
  end
end
