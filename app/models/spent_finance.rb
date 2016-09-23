class SpentFinance < ApplicationRecord
  include TimePeriodableValidated
  include WithMissingFinance

  belongs_to :finance_spendable, polymorphic: true

  validates :amount, presence: true
  validates :finance_spendable, presence: true
  validates :end_date,
            uniqueness: {
              scope: [
                :finance_spendable_type,
                :finance_spendable_id,
                :start_date
              ]
            }

  def parent
    finance_spendable
  end

  def parent=(new_parent)
    self.finance_spendable = new_parent
  end

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

  def amount_pretty
    ActionController::Base.helpers.number_with_delimiter(amount, delimiter: ',')
  end
end
