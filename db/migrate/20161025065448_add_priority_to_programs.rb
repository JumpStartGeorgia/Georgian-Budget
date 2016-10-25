class AddPriorityToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_reference :programs, :priority, foreign_key: true, index: true
  end
end
