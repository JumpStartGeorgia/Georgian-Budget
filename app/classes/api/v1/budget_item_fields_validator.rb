# UNTESTED

class API::V1::BudgetItemFieldsValidator
  def self.call(fields)
    return nil unless fields.present? && fields.is_a?(String)
    validated = fields.split(',').select do |field|
      valid = budget_item_permitted_fields.include? field
      unless valid
        raise API::V1::InvalidQueryError, "Budget item field \"#{field}\" not permitted. Allowed values: #{budget_item_permitted_fields.join(',')}"
      end
      valid
    end

    validated.map(&:underscore)
  end

  private

  def self.budget_item_permitted_fields
    add_camel_case_fields(item_fields_snake_case)
  end

  def self.item_fields_snake_case
    [
      'id',
      'code',
      'type',
      'name',
      'spent_finances',
      'planned_finances',
      'related_budget_items',
    ]
  end

  def self.add_camel_case_fields(fields)
    (fields + fields.map { |field| field.camelize(:lower) }).uniq
  end
end
