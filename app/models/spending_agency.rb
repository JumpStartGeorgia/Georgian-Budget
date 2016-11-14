class SpendingAgency < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include BudgetItemDuplicatable
  include ChildProgrammable

  belongs_to :priority
end
