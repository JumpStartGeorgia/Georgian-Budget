class AddSpendingAgencyToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_reference :programs, :spending_agency, foreign_key: true, index: true
  end
end
