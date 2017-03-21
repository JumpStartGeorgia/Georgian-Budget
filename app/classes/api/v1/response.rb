class API::V1::Response
  def initialize(budget_type_class, params)
    @budget_type_class = budget_type_class
    @errors = []
    @params = params

    filters = params['filters']

    if filters.present?
      @time_period_type = validate_time_period_type(filters['time_period_type']) if filters['time_period_type'].present?
    end

    @budget_item_fields = API::V1::BudgetItemFields.validate(params['budget_item_fields']) if params['budget_item_fields'].present?
  end

  def to_hash
    response = {}
    response[:errors] = errors

    unless budget_item_fields.present?
      self.budget_item_fields = 'id,code,name'
    end

    response[:budget_items] = []
    response[:budget_items] = get_budget_items_by_type
    return response
  end

  def add_error(text)
    self.errors = errors.push({
      text: text
    })
  end

  private

  attr_accessor :errors

  attr_reader :budget_type_class,
              :time_period_type,
              :budget_item_fields,
              :params

  def budget_items
    @budget_items ||= get_budget_items
  end

  def include_spent_finances(budget_items)
    case time_period_type
    when 'year'
      return budget_items.includes(:yearly_spent_finances)
    else
      return budget_items.includes(:spent_finances)
    end
  end

  def include_planned_finances(budget_items)
    case time_period_type
    when 'year'
      return budget_items.includes(:yearly_planned_finances)
    else
      return budget_items.includes(:planned_finances)
    end
  end

  def get_budget_items_by_type
    budget_items = budget_type_class.all
    budget_items = budget_items.with_most_recent_names if budget_item_fields.include?('name')
    budget_items = include_spent_finances(budget_items) if budget_item_fields.include?('spent_finances')
    budget_items = include_planned_finances(budget_items) if budget_item_fields.include?('planned_finances')

    return budget_items.map do |budget_item|
      budget_item_hash(budget_item)
    end
  end

  def budget_item_hash(budget_item)
    API::V1::BudgetItemHash.new(
      budget_item,
      fields: budget_item_fields,
      time_period_type: time_period_type
    ).to_hash
  end

  def validate_time_period_type(time_period_type)
    return nil unless time_period_type.present? && time_period_type.is_a?(String)

    unless time_period_type_permitted_fields.include? time_period_type
      raise API::V1::InvalidQueryError, "Time period type \"#{time_period_type}\" not permitted. Allowed values: #{time_period_type_permitted_fields.join(',')}"
    end

    time_period_type
  end

  def time_period_type_permitted_fields
    [
      'year',
      'quarter',
      'month'
    ]
  end
end
