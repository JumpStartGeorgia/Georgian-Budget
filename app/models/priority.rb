class Priority < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable

  has_many :programs

  # Updates the priority's finances by summing the finance amounts of the
  # priority's programs.
  def update_finances
    program_spent_finances = SpentFinance.select(
      'SUM(amount) AS amount, start_date, end_date'
    ).where(
      finance_spendable_type: 'Program',
      finance_spendable_id: programs.pluck(:id)
    ).group(
      :start_date,
      :end_date
    )

    program_spent_finances.each do |program_spent_finance|
      SpentFinance.create(
        finance_spendable: self,
        time_period: program_spent_finance.time_period,
        amount: program_spent_finance.amount
      )
    end
  end
end
