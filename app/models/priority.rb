class Priority < ApplicationRecord
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include PermaIdable

  has_many :connections,
           class_name: 'PriorityConnection'

  has_many :all_programs,
           -> { distinct },
           through: :connections,
           source: :priority_connectable,
           source_type: 'Program'

  has_many :child_programs,
           -> { distinct.where(parent_program: nil) },
           through: :connections,
           source: :priority_connectable,
           source_type: 'Program'

  has_many :spending_agencies,
           -> { distinct },
           through: :connections,
           source: :priority_connectable,
           source_type: 'SpendingAgency'

  def type
    self.class.to_s.underscore
  end
end
