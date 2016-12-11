class SpendingAgency < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include BudgetItemDuplicatable
  include PermaIdable

  belongs_to :priority

  has_many :child_programs,
           class_name: 'Program',
           as: :parent

  def type
    self.class.to_s.underscore
  end
end
