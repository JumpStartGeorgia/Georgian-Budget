class API::V1::TimePeriodTypeValidator
  def self.call(time_period_type)
    return nil unless time_period_type.present? && time_period_type.is_a?(String)

    unless time_period_type_permitted_fields.include? time_period_type
      raise API::V1::InvalidQueryError, "Time period type \"#{time_period_type}\" not permitted. Allowed values: #{time_period_type_permitted_fields.join(',')}"
    end

    time_period_type
  end

  private

  def self.time_period_type_permitted_fields
    [
      'year',
      'quarter',
      'month'
    ]
  end
end
