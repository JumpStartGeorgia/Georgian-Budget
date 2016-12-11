class SpendingAgency < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include BudgetItemDuplicatable
  include PermaIdable

  belongs_to :priority

  has_many :child_programs,
           -> { where(parent_program: nil) },
           class_name: 'Program'

  has_many :programs

  def type
    self.class.to_s.underscore
  end

  def take_programs_from(other_agency)
    other_agency.programs.update(spending_agency: self)
  end
end
