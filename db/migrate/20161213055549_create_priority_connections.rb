class CreatePriorityConnections < ActiveRecord::Migration[5.0]
  def change
    create_table :priority_connections do |t|
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.boolean :direct, index: true
      t.references :priority, foreign_key: true, index: true
      t.references :priority_connectable,
                   polymorphic: true,
                   index: {
                     name: 'index_priority_connection_on_priority_connectable'
                   }

      t.timestamps
    end
  end
end
