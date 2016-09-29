class APIResponse
  def initialize(params)
    filters = params['filters']

    if filters.present?
      @budget_item_type = filters['budget_item_type'] if filters['budget_item_type'].present?
    end

    @budget_item_fields = params['budget_item_fields'] if params['budget_item_fields']
    @budget_item_ids = params['budgetItemIds'] if params['budgetItemIds']
    @finance_type = params['financeType']
    @errors = []
  end

  def to_json
    response = {}
    response['errors'] = errors

    response['budget_items'] = budget_items if budget_items
  rescue
    add_error('Failed to process the request')
  ensure
    return response
  end

  def add_error(text)
    self.errors = errors.push({
      text: text
    })
  end

  private

  attr_accessor :errors

  attr_reader :budget_item_ids, :finance_type, :budget_item_fields, :budget_item_type

  def budget_items
    if budget_item_fields.present?
      budget_items = Object.const_get(budget_item_type.camelize).with_most_recent_names

      return budget_items.map do |budget_item|
        {
          'id': budget_item.id,
          'name': budget_item.name
        }
      end
    end

    budget_item_ids.map { |id| budget_item(id) }
  end

  def budget_item(id)
    begin
      budget_item = Program.find(id)
    rescue ActiveRecord::RecordNotFound
      addError('Could not find budget item')
      return nil
    end

    if finance_type == 'planned_finance'
      finances = budget_item.planned_finances
    elsif finance_type == 'spent_finance'
      finances = budget_item.spent_finances
    else
      addError("No #{finance_type} finance type available")
      return nil
    end

    finances = finances.with_missing_finances.sort_by { |finance| finance.start_date }

    name = budget_item.name

    time_periods = finances.map { |finance| finance.time_period.to_s }

    amounts = finances.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end

    {
      chart_name: I18n.t("activerecord.models.#{finance_type}.other"),
      name: name,
      time_periods: time_periods,
      amounts: amounts
    }
  end
end
