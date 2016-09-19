module FinanceSpendable
  extend ActiveSupport::Concern

  included do
    has_many :spent_finances, -> { order 'spent_finances.start_date' }, as: :finance_spendable, dependent: :destroy
  end
end
