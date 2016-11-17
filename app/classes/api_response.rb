class APIResponse
  def initialize(params)
    @errors = []

    filters = params['filters']

    if filters.present?
      @budget_item_type = filters['budget_item_type'] if filters['budget_item_type'].present?
      @time_period_type = filters['time_period_type'] if filters['time_period_type'].present?
      @finance_type = filters['finance_type'] if filters['finance_type'].present?
    end

    @budget_item_fields = validate_budget_item_fields(params['budget_item_fields']) if params['budget_item_fields'].present?
    @budget_item_ids = params['budget_item_ids'] if params['budget_item_ids'].present?
  end

  def to_hash
    response = {}
    response[:errors] = errors

    response[:budget_items] = budget_items if budget_items
  rescue StandardError => error
    add_error("Failed to process the request: #{error}")
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

  attr_reader :budget_item_ids,
              :finance_type,
              :time_period_type,
              :budget_item_fields,
              :budget_item_type

  def budget_items
    if budget_item_fields.present?
      if budget_type_class == Total
        budget_items = [Total.first]
      else
        budget_items = budget_type_class.with_most_recent_names
      end

      return budget_items.map do |budget_item|
        budget_item_hash(budget_item)
      end
    end

    budget_item_ids.map { |id| budget_item_config(id) }
  end

  def budget_item_hash(budget_item)
    hash = {}

    hash['id'] = budget_item.perma_id if budget_item_fields.include? 'id'
    hash['name'] = budget_item.name if budget_item_fields.include? 'name'

    hash
  end

  def validate_budget_item_fields(fields)
    return nil unless fields.present? && fields.is_a?(String)
    fields.split(',').select do |field|
      valid = budget_item_permitted_fields.include? field
      add_error("Budget item field \"#{field}\" not permitted") unless valid
      valid
    end
  end

  def budget_item_permitted_fields
    [
      'id',
      'name'
    ]
  end

  def budget_item_config(id)
    begin
      budget_item = budget_type_class.find(id)
    rescue ActiveRecord::RecordNotFound
      add_error('Could not find budget item')
      return nil
    end

    if finance_type == 'planned_finance'
      finances = budget_item.planned_finances
    elsif finance_type == 'spent_finance'
      finances = budget_item.spent_finances
    else
      add_error("No #{finance_type} finance type available")
      return nil
    end

    if ['monthly', 'quarterly', 'yearly'].include? time_period_type
      finances = finances.send(time_period_type)
    else
      add_error("Time period type #{time_period_type} is not available")
    end

    finances = finances.sort_by { |finance| finance.start_date }

    name = budget_item.name

    time_periods = finances.map { |finance| finance.time_period.to_s }

    amounts = finances.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end

    {
      id: id,
      type: budget_item.class.to_s.underscore,
      finance_type: I18n.t("activerecord.models.#{finance_type}.other"),
      time_period_type: time_period_type,
      name: name,
      time_periods: time_periods,
      amounts: amounts
    }
  end

  def budget_type_class
    unless budget_item_type.present?
      raise 'Budget item type filter parameter is required'
    end

    camelized = budget_item_type.camelize

    unless allowed_budget_item_types.include? camelized
      raise "Budget item type #{budget_item_type} is not available"
    end

    Object.const_get(camelized)
  end

  def allowed_budget_item_types
    ['Program', 'SpendingAgency', 'Priority', 'Total']
  end
end
