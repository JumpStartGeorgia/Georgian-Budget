class SpendingAgency < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
end
