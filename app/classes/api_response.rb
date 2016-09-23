class APIResponse
  def initialize(params)
    @budget_item_ids = params['budgetItemIds'] if params['budgetItemIds']
    @error = nil
  end

  def to_json
    response = {}

    response['budget_items'] = budget_items if budget_items
    response['error'] = error if error

    response
  end

  private

  attr_accessor :error

  attr_reader :budget_item_ids

  def budget_items
    budget_item_ids.map { |id| chart_config_for_program(id) }
  end

  def chart_config_for_program(id)
    begin
      budget_item = Program.find(id)
    rescue ActiveRecord::RecordNotFound
      self.error = 'Could not find budget item'
      return nil
    end

    spent_finances = budget_item.spent_finances.with_missing_finances.sort_by { |finance| finance.start_date }

    name = budget_item.name

    time_period_months = spent_finances.map(&:month).map { |month| month.to_s }

    amounts = spent_finances.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end

    {
      name: name,
      time_periods: time_period_months,
      amounts: amounts
    }
  end
end
