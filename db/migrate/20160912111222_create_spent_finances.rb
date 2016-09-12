class CreateSpentFinances < ActiveRecord::Migration[5.0]
  def change
    create_table :spent_finances do |t|
      t.integer :amount
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.references :finance_spendable,
                   polymorphic: true,
                   index: {
                     name: 'index_spent_finances_on_finance_spendable'
                   }

      t.timestamps
    end
  end
end
