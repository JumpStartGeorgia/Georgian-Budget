module TimePeriodableValidated
  extend ActiveSupport::Concern
  include TimePeriodable

  included do
    validates_with StartEndDateValidator
    validate :validate_time_period_type_is_recognizable

    def self.with_time_period(time_period)
      where(start_date: time_period.start_date, end_date: time_period.end_date)
    end

    before_save :set_time_period_type
  end

  private

  def validate_time_period_type_is_recognizable
    return if start_date.blank?
    return if end_date.blank?
    
    if get_time_period_type_from_dates.nil?
      errors.add(:time_period_type, "of start and end date is unrecognized")
    end
  end

  def set_time_period_type
    self[:time_period_type] = get_time_period_type_from_dates
  end

  def get_time_period_type_from_dates
    return 'month' if Month.dates_valid?(start_date, end_date)
    return 'quarter' if Quarter.dates_valid?(start_date, end_date)

    nil
  end
end
