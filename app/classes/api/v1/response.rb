class API::V1::Response
  def initialize(budget_type_class, params = {})
    @budget_type_class = budget_type_class
    @errors = []
    @time_period_type = params[:time_period_type]
    @budget_item_fields = params[:fields]
  end

  def to_hash
    response = {}
    response[:errors] = errors

    unless budget_item_fields.present?
      self.budget_item_fields = 'id,code,name,type'
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

  attr_accessor :errors,
                :budget_item_fields

  attr_reader :budget_type_class,
              :time_period_type

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
end
