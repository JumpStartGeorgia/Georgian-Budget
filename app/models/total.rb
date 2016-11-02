class Total < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable

  private

  def override_name_attributes(name_attributes)
    name_attributes[:text_ka] = 'მთლიანი სახელმწიფო ბიუჯეტი'
    name_attributes[:text_en] = 'Complete Government Budget'
  end
end
