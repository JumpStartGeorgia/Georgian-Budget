class API::V1::BudgetItemHash
  def initialize(budget_item, fields)
    @budget_item = budget_item
    @fields = fields
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
        hash['spent_finances'] = budget_item.spent_finances.map do |f|
          {
            amount: f.amount.present? ? f.amount.to_f : nil,
            time_period: f.time_period.to_s,
            time_period_type: f.time_period_type
          }
        end
      end

      if fields.include? 'planned_finances'
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

  attr_reader :budget_item,
              :fields
end
