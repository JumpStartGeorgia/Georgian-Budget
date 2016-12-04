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
                :end_date,
                :official
              ]
            }
  validates :primary, inclusion: { in: [true, false] }
  validates :official, inclusion: { in: [true, false] }

  before_validation :set_primary_default

  def budget_item
    finance_plannable
  end

  def budget_item=(budget_item)
    self.finance_plannable = budget_item
  end

  def siblings
    budget_item.planned_finances
  end

  def all_siblings
    budget_item.all_planned_finances
  end

  def versions
    all_siblings.with_time_period(time_period_obj)
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

  def self.prefer_official
    ids = self.find_by_sql(
      <<-STRING
        SELECT DISTINCT ON (finance_plannable_type,
                            finance_plannable_id,
                            start_date,
                            end_date,
                            announce_date)
                            id
        FROM planned_finances
        ORDER BY finance_plannable_type,
                 finance_plannable_id,
                 start_date,
                 end_date,
                 announce_date,
                 official DESC
      STRING
    )

    where(id: ids)
  end

  def ==(other_planned_finance)
    return false if other_planned_finance.class != self.class
    return false if finance_plannable != other_planned_finance.finance_plannable
    return false if start_date != other_planned_finance.start_date
    return false if end_date != other_planned_finance.end_date
    return false if official != other_planned_finance.official

    if announce_date != other_planned_finance.announce_date
      return false if amount != other_planned_finance.amount
    end

    return true
  end

  def amount_pretty
    return nil if amount.nil?
    ActionController::Base.helpers.number_with_delimiter(amount, delimiter: ',')
  end

  private

  def set_primary_default
    self.primary = false if primary.nil?
  end
end
