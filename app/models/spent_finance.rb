class SpentFinance < ApplicationRecord
  include TimePeriodable
  include Amountable

  belongs_to :finance_spendable, polymorphic: true

  validates_with StartEndDateValidator
  validates :finance_spendable, presence: true
  validates :end_date,
            uniqueness: {
              scope: [
                :finance_spendable_type,
                :finance_spendable_id,
                :start_date,
                :official
              ]
            }
  validates :primary, inclusion: { in: [true, false] }
  validates :official, inclusion: { in: [true, false] }

  before_validation :set_primary_default

  def self.budget_item_id_field
    :finance_spendable_id
  end

  def self.budget_item_type_field
    :finance_spendable_type
  end

  def budget_item
    finance_spendable
  end

  def budget_item=(budget_item)
    self.finance_spendable = budget_item
  end

  def siblings
    budget_item.spent_finances
  end

  def all_siblings
    budget_item.all_spent_finances
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

  def self.primary
    where(primary: true)
  end

  def self.prefer_official
    ids = self.find_by_sql(
      <<-STRING
        SELECT DISTINCT ON (finance_spendable_type,
                            finance_spendable_id,
                            start_date,
                            end_date)
                            id
        FROM spent_finances
        ORDER BY finance_spendable_type,
                 finance_spendable_id,
                 start_date,
                 end_date,
                 official DESC
      STRING
    )

    where(id: ids)
  end

  def amount_pretty
    ActionController::Base.helpers.number_with_delimiter(amount, delimiter: ',')
  end

  private

  def set_primary_default
    self.primary = false if primary.nil?
  end
end
