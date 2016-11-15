class CreatePermaIds < ActiveRecord::Migration[5.0]
  def change
    create_table :perma_ids do |t|
      t.string :text, index: true
      t.references :perma_idable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
