class AddParentProgramToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_reference :programs, :parent_program, references: :programs, index: true
    add_foreign_key :programs, :programs, column: :parent_program_id
  end
end
