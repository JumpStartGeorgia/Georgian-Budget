class CreateCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :codes do |t|
      t.date :start_date, index: true
      t.string :number
      t.references :codeable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
