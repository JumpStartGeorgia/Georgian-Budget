module FinanceSpendable
  extend ActiveSupport::Concern

  included do
    has_many :all_spent_finances,
             -> { order('spent_finances.start_date') },
             as: :finance_spendable,
             class_name: 'SpentFinance',
             dependent: :destroy

    has_many :spent_finances,
             -> { primary.order('spent_finances.start_date') },
             as: :finance_spendable

    has_many :yearly_spent_finances,
             -> { primary.order('spent_finances.start_date').where(time_period_type: 'year') },
             as: :finance_spendable,
             class_name: 'SpentFinance'
  end

  module ClassMethods
    def with_spent_finances
      includes(:spent_finances)
    end
  end

  def add_spent_finance(spent_finance_attributes, args = {})
    transaction do
      spent_finance_attributes[:finance_spendable] = self
      new_spent_finance = SpentFinance.create!(spent_finance_attributes)

      update_with_new_spent_finance(new_spent_finance, args)

      args[:return_finance] ? new_spent_finance : self
    end
  end

  def take_spent_finance(new_spent_finance, args = {})
    transaction do
      new_spent_finance.update_attributes!(finance_spendable: self)

      update_with_new_spent_finance(new_spent_finance, args)

      args[:return_finance] ? new_spent_finance : self
    end
  end

  private

  def update_with_new_spent_finance(new_spent_finance, args = {})
    FinanceCategorizer.new(new_spent_finance).set_primary
    DatesUpdater.new(self, new_spent_finance).update
  end
end
