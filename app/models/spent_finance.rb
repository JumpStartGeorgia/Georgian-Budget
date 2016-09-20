class SpentFinance < ApplicationRecord
  validates_with StartEndDateValidator

  belongs_to :finance_spendable, polymorphic: true

  validates :amount, presence: true
  validates :finance_spendable, presence: true
  validates :end_date, uniqueness: { scope: [:finance_spendable, :start_date] }

  def self.year_cumulative_up_to(date)
    after(Date.new(date.year, 1, 1)).before(date).total
  end

  def self.before(date)
    where('end_date <= ?', date)
  end

  def self.after(date)
    where('start_date >= ?', date)
  end

  def self.total
    calculate(:sum, :amount)
  end

  def self.with_missing_finances
    # only configured to work with monthly time periods

    start_dates = pluck(:start_date)
    start_date_months = start_dates.map do |date|
      [date.month, date.year]
    end

    first_start_date = order(:start_date).first.start_date
    last_start_date = order(:start_date).last.start_date

    # start with month after first date
    # if exists in array then move to next month
    # if does not exist in array then add a missing finance for it
    # stop when reach last date
    array_of_finances = all.to_a
    date = first_start_date

    while date < last_start_date
      date = date.next_month
      next if start_date_months.include? [date.month, date.year]

      array_of_finances.push(
        MissingFinance.new(
          start_date: date.beginning_of_month,
          end_date: date.end_of_month)
      )
    end

    array_of_finances
  end

  def amount_pretty
    ActionController::Base.helpers.number_with_delimiter(amount, delimiter: ',')
  end
end
