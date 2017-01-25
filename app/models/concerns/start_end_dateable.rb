module StartEndDateable
  extend ActiveSupport::Concern

  module ClassMethods
    def with_time_period(time_period)
      where(start_date: time_period.start_date, end_date: time_period.end_date)
    end

    def within_time_period(time_period)
      where(
        arel_table[:start_date].gteq(time_period.start_date)
        .and(arel_table[:end_date].lteq(time_period.end_date))
      )
    end

    def before(date)
      where(arel_table[:end_date].lteq(date))
    end

    def after(date)
      where(arel_table[:start_date].gteq(date))
    end
  end

  def time_period_obj
    return time_period_class.for_date(start_date) if time_period_class.present?
    nil
  end

  def time_period_obj=(time_period_obj)
    return if time_period_obj.blank?

    self.start_date = time_period_obj.start_date
    self.end_date = time_period_obj.end_date
  end

  def time_period_class
    return Month if Month.dates_valid?(start_date, end_date)
    return Quarter if Quarter.dates_valid?(start_date, end_date)
    return Year if Year.dates_valid?(start_date, end_date)

    nil
  end
end
