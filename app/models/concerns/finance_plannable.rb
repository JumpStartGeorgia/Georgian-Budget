module FinancePlannable
  extend ActiveSupport::Concern

  included do
    has_many :planned_finances, -> { order 'planned_finances.start_date' }, as: :finance_plannable, dependent: :destroy
  end
end
