class FinanceCategorizer
  def initialize(finance)
    @finance = finance
  end

  def set_primary
    if matching_siblings.count == 1
      finance.update_attributes(primary: true) unless finance.primary
      return
    end

    matching_siblings.update(primary: false)
    matching_siblings.official.update(primary: true)
  end

  private

  attr_reader :finance, :matching_siblings

  # Finances that belong to same budget item and have same time period
  def matching_siblings
    finance
    .finance_spendable
    .spent_finances
    .with_time_period(finance.time_period_obj)
  end
end
