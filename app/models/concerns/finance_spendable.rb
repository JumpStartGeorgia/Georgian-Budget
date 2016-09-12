module FinanceSpendable
  extend ActiveSupport::Concern

  included do
    has_many :spent_finances, as: :finance_spendable
  end
end
