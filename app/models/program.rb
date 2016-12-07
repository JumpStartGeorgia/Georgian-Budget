class Program < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable
  include BudgetItemDuplicatable
  include ChildProgrammable
  include PermaIdable

  belongs_to :priority
  belongs_to :parent, polymorphic: true

  def parent_program
    
  end

  def update_parent
    update_attribute(:parent, find_parent_codeable)
  end

  def type
    self.class.to_s.underscore
  end

  private

  def find_parent_codeable
    return nil if codes.blank?
    codes.last.parent_codeable
  end
end
