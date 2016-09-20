class TimeSeriesChart
  def initialize(budget_item, item_data)
    @budget_item = budget_item
    @unformatted_data = item_data
  end

  def config
    {
      name: budget_item.name,
      data: data
    }
  end

  attr_reader :budget_item, :unformatted_data

  private

  def data
    {
      time_periods: time_period_months,
      amounts: amounts
    }
  end

  def amounts
    unformatted_data.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end
  end

  def time_period_months
    unformatted_data.map(&:month).map { |month| month.strftime('%B, %Y') }
  end
end
