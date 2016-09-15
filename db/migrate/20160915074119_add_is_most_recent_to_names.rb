class AddIsMostRecentToNames < ActiveRecord::Migration[5.0]
  def up
    add_column :names, 
               :is_most_recent, 
               :boolean, 
               index: true, 
               null: false, 
               default: false
  end

  def down
    remove_column :names,
                  :is_most_recent              
  end
end
