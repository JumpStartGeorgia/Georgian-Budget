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

  has_many :all_programs,
           class_name: 'Program'

  has_many :priority_connections, as: :priority_connectable

  def direct_priority_connections
    priority_connections.direct
  end

  def type
    self.class.to_s.underscore
  end

  def take_programs_from(other_agency)
    other_agency.all_programs.update(spending_agency: self)
  end

  def ancestors
    []
  end
end
