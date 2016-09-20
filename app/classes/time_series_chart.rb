class TimeSeriesChart
  def initialize(budget_item, unformatted_data)
    @budget_item = budget_item
    @time_period_months = unformatted_data.map(&:month).map { |month| month.strftime('%B, %Y') }
    @amounts = unformatted_data.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end
  end

  def config
    {
      name: budget_item.name,
      data: data
    }
  end

  attr_reader :budget_item, :time_period_months, :amounts

  private

  def data
    {
      time_periods: time_period_months,
      amounts: amounts
    }
  end
end
