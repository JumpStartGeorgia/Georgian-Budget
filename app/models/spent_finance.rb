class SpentFinance < ApplicationRecord
  belongs_to :finance_spendable, polymorphic: true

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
end
