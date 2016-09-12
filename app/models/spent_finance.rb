class SpentFinance < ApplicationRecord
  belongs_to :finance_spendable, polymorphic: true
end
