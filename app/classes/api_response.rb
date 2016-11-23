class APIQueryInvalidError < StandardError
end

class APIResponse
  def initialize(params)
    @errors = []
    @params = params

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
    return response
  rescue APIQueryInvalidError => e
    add_error("Failed to process the request: #{e.message}")
    response[:budget_items] = []
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
              :budget_item_type,
              :params

  def budget_items
    @budget_items ||= get_budget_items
  end

  def get_budget_items
    unless budget_item_fields.present?
      raise APIQueryInvalidError, 'budgetItemFields must be supplied in query'
    end

    if budget_item_ids.present?
      budget_items = budget_item_ids.map do |perma_id|
        item = BudgetItem.find_by_perma_id(perma_id)
        unless item.present?
          raise APIQueryInvalidError, "budget item with id #{perma_id} does not exist"
        end

        item
      end
    elsif budget_item_type.present?
      budget_items = budget_type_class.all
    else
      raise APIQueryInvalidError, 'budgetItemIds or budgetItemType filter must be supplied in query'
    end

    return budget_items.map do |budget_item|
      budget_item_hash(budget_item)
    end
  end

  def budget_item_hash(budget_item)
    Hash.new.tap do |hash|
      hash['id'] = budget_item.perma_id if budget_item_fields.include? 'id'
      hash['code'] = budget_item.code if budget_item_fields.include? 'code'
      hash['name'] = budget_item.name if budget_item_fields.include? 'name'
      hash['type'] = budget_item.type if budget_item_fields.include? 'type'

      if budget_item_fields.include? 'spent_finances'
        hash['spent_finances'] = budget_item.spent_finances.map do |f|
          {
            amount: f.amount.present? ? f.amount.to_f : nil,
            time_period: f.time_period.to_s,
            time_period_type: f.time_period_type
          }
        end
      end

      if budget_item_fields.include? 'planned_finances'
        hash['planned_finances'] = budget_item.planned_finances.map do |f|
          {
            amount: f.amount.present? ? f.amount.to_f : nil,
            time_period: f.time_period.to_s,
            time_period_type: f.time_period_type
          }
        end
      end
    end
  end

  def validate_budget_item_fields(fields)
    return nil unless fields.present? && fields.is_a?(String)
    fields.split(',').select do |field|
      valid = budget_item_permitted_fields.include? field
      unless valid
        raise APIQueryInvalidError, "Budget item field \"#{field}\" not permitted"
      end
      valid
    end
  end

  def budget_item_permitted_fields
    [
      'id',
      'code',
      'type',
      'name',
      'spent_finances',
      'planned_finances'
    ]
  end

  def budget_type_class
    camelized = budget_item_type.camelize

    unless allowed_budget_item_types.include? camelized
      raise APIQueryInvalidError, "Budget item type #{budget_item_type} is not available"
    end

    Object.const_get(camelized)
  end

  def allowed_budget_item_types
    ['Program', 'SpendingAgency', 'Priority', 'Total']
  end
end
