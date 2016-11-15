class Total < ApplicationRecord
  include FinanceSpendable
  include FinancePlannable
  include PermaIdable

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
end
