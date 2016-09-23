module WithMissingFinance
  extend ActiveSupport::Concern

  module ClassMethods

    # 1) start with the time period of the oldest finance
    # 2) insert MissingFinance for all missing time periods
    #    up until time period of most recent finance
    def with_missing_finances
      # use time period type of first time period
      time_period_class = first.time_period_class

      time_periods = pluck(:start_date).map do |date|
        time_period_class.for_date(date)
      end

      array_of_finances = all.to_a
      inc_time_period = time_periods.first

      while (inc_time_period <=> time_periods.last) == -1
        inc_time_period = inc_time_period.next
        next if time_periods.include? inc_time_period

        array_of_finances.push(
          MissingFinance.new(inc_time_period.to_hash)
        )
      end

      array_of_finances
    end
  end
end
