module FinanceSpendable
  extend ActiveSupport::Concern

  included do
    has_many :spent_finances,
             -> { order('spent_finances.start_date') },
             as: :finance_spendable,
             dependent: :destroy
  end

  def add_spent_finance(spent_finance_attributes, args = {})
    transaction do
      spent_finance_attributes[:finance_spendable] = self
      new_spent_finance = SpentFinance.create!(spent_finance_attributes)

      update_with_new_spent_finance(new_spent_finance, args)

      args[:return_spent_finance] ? new_spent_finance : self
    end
  end

  def take_spent_finance(new_spent_finance, args = {})
    transaction do
      new_spent_finance.update_attributes!(finance_spendable: self)

      update_with_new_spent_finance(new_spent_finance, args)

      args[:return_spent_finance] ? new_spent_finance : self
    end
  end

  def update_with_new_spent_finance(new_spent_finance, args = {})
    if args[:cumulative_within].present?
      new_spent_finance.update_attributes!(
        amount: NonCumulativeFinanceCalculator.new(
          finances: spent_finances,
          cumulative_amount: new_spent_finance.amount,
          time_period: new_spent_finance.time_period,
          cumulative_within: args[:cumulative_within]
        ).calculate
      )
    end

    DatesUpdater.new(self, new_spent_finance).update
  end
end
