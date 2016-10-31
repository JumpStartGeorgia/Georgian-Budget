class CreatePossibleDuplicatePairs < ActiveRecord::Migration[5.0]
  def change
    create_table :possible_duplicate_pairs do |t|
      t.references :item1,
                   index: {
                     name: 'index_item1'
                   }

      t.references :item2,
                   index: {
                     name: 'index_item2'
                   }

      t.string :pair_type
    end
  end
end
