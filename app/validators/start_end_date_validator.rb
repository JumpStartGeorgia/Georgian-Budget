# Validates presence of start date and end date, and ensures that end date
# is on or after start date
class StartEndDateValidator < ActiveModel::Validator
  def validate(record)
    if record.start_date.nil?
      record.errors[:start_date] << 'Start date must be present'
      return false
    end

    if record.end_date.nil?
      record.errors[:end_date] << 'End date must be present'
      return false
    end

    if record.end_date < record.start_date
      record.errors[:end_date] << 'End date must be on or after start_date'
    end

    return true
  end
end
