class API::V1::BudgetItemHash
  def initialize(budget_item, options)
    @budget_item = budget_item
    @fields = options[:fields]
    @time_period_type = options[:time_period_type]
  end

  def to_hash
    Hash.new.tap do |hash|
      hash['id'] = budget_item.perma_id if fields.include? 'id'

      if (fields.include? 'code') && (budget_item.respond_to? 'code')
        hash['code'] = budget_item.code
      end

      hash['name'] = budget_item.name if fields.include? 'name'
      hash['type'] = budget_item.type if fields.include? 'type'

      if fields.include? 'spent_finances'
        hash['spent_finances'] = if time_period_type.present?
          budget_item.spent_finances.where(time_period_type: time_period_type)
        else
          budget_item.spent_finances
        end
      end

      if fields.include? 'planned_finances'
        hash['planned_finances'] = if time_period_type.present?
          budget_item.planned_finances.where(time_period_type: time_period_type)
        else
          budget_item.planned_finances
        end
      end
    end
  end

  attr_reader :budget_item,
              :fields,
              :time_period_type
end
