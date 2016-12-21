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
        hash['spent_finances'] = get_spent_finances(budget_item)
      end

      if fields.include? 'planned_finances'
        hash['planned_finances'] = get_planned_finances(budget_item)
      end

      if fields.include? 'related_budget_items'
        set_overall_budget(hash)
        set_child_programs(hash)
        set_priorities(hash)
        hash['spendingAgencies'] = get_spending_agencies if budget_item.respond_to?(:spending_agencies)
        hash['spendingAgency'] = get_spending_agency if budget_item.respond_to?(:spending_agency)
        hash['parentProgram'] = get_parent_program if budget_item.respond_to?(:parent_program)
      end
    end
  end

  attr_reader :budget_item,
              :fields,
              :time_period_type

  private

  def get_spent_finances(budget_item)
    case time_period_type
    when 'year'
      budget_item.yearly_spent_finances
    else
      budget_item.spent_finances
    end
  end

  def get_planned_finances(budget_item)
    case time_period_type
    when 'year'
      budget_item.yearly_planned_finances
    else
      budget_item.planned_finances
    end
  end

  def set_overall_budget(hash)
    return if budget_item.perma_id == Total.first.perma_id
    hash['overall_budget'] = Hash.new.tap do |h|
      h['id'] = Total.first.perma_id
      h['name'] = Total.first.name
    end
  end

  def get_parent_program
    return nil if budget_item.parent_program.blank?
    Hash.new.tap do |h|
      h['id'] = budget_item.parent_program.perma_id
      h['name'] = budget_item.parent_program.name
    end
  end

  def get_spending_agency
    return nil if budget_item.spending_agency.blank?
    Hash.new.tap do |h|
      h['id'] = budget_item.spending_agency.perma_id
      h['name'] = budget_item.spending_agency.name
    end
  end

  def set_child_programs(hash)
    return unless budget_item.respond_to?(:child_programs)

    hash['child_programs'] = budget_item.child_programs.pluck(:perma_id).map do |child_program_perma_id|
      {
        id: child_program_perma_id
      }
    end
  end

  def set_priorities(hash)
    return unless budget_item.respond_to?(:priorities)

    hash['priorities'] = budget_item.priorities.pluck(:perma_id).map do |perma_id|
      {
        id: perma_id
      }
    end
  end

  def get_spending_agencies
    budget_item.spending_agencies.pluck(:perma_id).map do |perma_id|
      {
        id: perma_id
      }
    end
  end
end
