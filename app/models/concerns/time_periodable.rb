module TimePeriodable
  extend ActiveSupport::Concern
  include StartEndDateable

  included do
    validate :validate_time_period_type_is_recognizable

    before_save :set_time_period_type
    before_save :set_time_period
  end

  module ClassMethods
    def monthly
      where(time_period_type: Month.type_to_s)
    end

    def quarterly
      where(time_period_type: Quarter.type_to_s)
    end

    def yearly
      where(time_period_type: Year.type_to_s)
    end
  end

  private

  def validate_time_period_type_is_recognizable
    return if start_date.blank?
    return if end_date.blank?

    if time_period_class.nil?
      errors.add(:time_period_type, "of start and end date is unrecognized")
    end
  end

  def set_time_period_type
    self[:time_period_type] = get_time_period_type
  end

  def get_time_period_type
    return time_period_class.type_to_s if time_period_class.present?
    nil
  end

  def set_time_period
    self[:time_period] = time_period_obj.to_s
  end
end
