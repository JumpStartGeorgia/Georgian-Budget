class StartEndDateValidator < ActiveModel::Validator
  def validate(record)
    return if record.end_date.nil? || record.start_date.nil?
    return true if record.end_date >= record.start_date

    record.errors[:end_date] << 'End date must be on or after start_date'
  end
end
