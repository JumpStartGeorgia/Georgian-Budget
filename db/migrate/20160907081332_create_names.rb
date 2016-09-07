class CreateNames < ActiveRecord::Migration[5.0]
  def up
    create_table :names do |t|
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.references :nameable, polymorphic: true, index: true
      t.timestamps
    end

    Name.create_translation_table! text: :string
  end

  def down
    drop_table :names
    Name.drop_translation_table!
  end
end
