class AddDateWhenFoundToPossibleDuplicatePairs < ActiveRecord::Migration[5.0]
  def change
    add_column :possible_duplicate_pairs, :date_when_found, :date
  end
end
