class CreatePlannedFinances < ActiveRecord::Migration[5.0]
  def change
    create_table :planned_finances do |t|
      t.decimal :amount, precision: 14, scale: 2
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.references :finance_plannable,
                   polymorphic: true,
                   index: {
                     name: 'index_planned_finances_on_finance_plannable'
                   }

      t.timestamps
    end
  end
end
