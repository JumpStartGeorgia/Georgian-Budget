module TimePeriodableValidated
  extend ActiveSupport::Concern
  include TimePeriodable

  included do
    validates_with StartEndDateValidator

    def self.with_time_period(time_period)
      where(start_date: time_period.start_date, end_date: time_period.end_date)
    end
  end
end
