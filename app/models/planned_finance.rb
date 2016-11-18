class PlannedFinance < ApplicationRecord
  include TimePeriodable

  belongs_to :finance_plannable, polymorphic: true

  validates :finance_plannable, presence: true
  validates :announce_date,
            presence: true,
            uniqueness: {
              scope: [
                :finance_plannable_type,
                :finance_plannable_id,
                :start_date,
                :end_date
              ]
            },
            if: :official
  validates :official, inclusion: { in: [true, false] }

  def parent
    finance_plannable
  end

  def parent=(new_parent)
    self.finance_plannable = new_parent
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

  def self.official
    where(official: true)
  end

  def self.unofficial
    where(official: false)
  end

  def ==(other_planned_finance)
    return false if other_planned_finance.class != self.class
    return false if finance_plannable != other_planned_finance.finance_plannable
    return false if start_date != other_planned_finance.start_date
    return false if end_date != other_planned_finance.end_date

    if announce_date != other_planned_finance.announce_date
      return false if amount != other_planned_finance.amount
    end

    return true
  end

  def amount_pretty
    return nil if amount.nil?
    ActionController::Base.helpers.number_with_delimiter(amount, delimiter: ',')
  end
end
