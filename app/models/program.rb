class Program < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include BudgetItemDuplicatable
  include PermaIdable

  belongs_to :priority
  belongs_to :spending_agency
  belongs_to :parent_program, class_name: 'Program'

  has_many :child_programs,
           class_name: 'Program',
           foreign_key: :parent_program_id

  has_many :priority_connections, as: :priority_connectable

  def direct_priority_connections
    priority_connections.direct
  end

  def type
    self.class.to_s.underscore
  end

  def take_programs_from(other_program)
    other_program.child_programs.update(parent_program: self)
  end
end
