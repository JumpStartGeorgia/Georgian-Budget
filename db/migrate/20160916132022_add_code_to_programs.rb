class AddCodeToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :code, :string
  end
end
