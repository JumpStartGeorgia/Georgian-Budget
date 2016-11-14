class AddParentToProgram < ActiveRecord::Migration[5.0]
  def change
    add_reference :programs,
                  :parent,
                  polymorphic: true,
                  index: true
  end
end
