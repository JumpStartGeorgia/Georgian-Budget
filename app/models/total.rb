class Total < ApplicationRecord
  include FinanceSpendable
  include FinancePlannable
  include PermaIdable

  def type
    self.class.to_s.underscore
  end

  def code
    '00'
  end

  def name
    send("name_#{I18n.locale}".to_sym)
  end

  def name_ka
    'მთლიანი სახელმწიფო ბიუჯეტი'
  end

  def name_en
    'Complete National Budget'
  end

  def child_programs
    Program.all.where.not(parent_type: 'Program')
  end

  def priorities
    Priority.all
  end

  def spending_agencies
    SpendingAgency.all
  end
end
