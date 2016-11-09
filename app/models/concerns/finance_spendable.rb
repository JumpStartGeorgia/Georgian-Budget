module FinanceSpendable
  extend ActiveSupport::Concern

  included do
    has_many :spent_finances,
             -> { order('spent_finances.start_date') },
             as: :finance_spendable,
             dependent: :destroy
  end

  def add_spent_finance(spent_finance_attributes)
    transaction do
      spent_finance_attributes[:finance_spendable] = self
      spent_finance = SpentFinance.create!(spent_finance_attributes)

      DatesUpdater.new(self, spent_finance).update

      return self
    end
  end
end
