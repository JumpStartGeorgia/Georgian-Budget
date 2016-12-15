class PriorityConnection < ApplicationRecord
  belongs_to :priority
  belongs_to :priority_connectable, polymorphic: true

  validates_with StartEndDateValidator
  validates :priority, presence: true
  validates :priority_connectable, presence: true
  validates :direct, inclusion: { in: [true, false] }
  validate :validate_has_no_duplicates

  def self.direct
    where(direct: true)
  end

  def self.indirect
    where(direct: false)
  end

  def time_period_obj=(time_period_obj)
    return if time_period_obj.blank?

    self.start_date = time_period_obj.start_date
    self.end_date = time_period_obj.end_date
  end

  def time_period_obj
    time_period_class.for_date(start_date)
  end

  def time_period_class
    time_period_type = get_time_period_type_from_dates

    return Month if time_period_type == Month.type_to_s
    return Quarter if time_period_type == Quarter.type_to_s
    return Year if time_period_type == Year.type_to_s

    nil
  end

  def get_time_period_type_from_dates
    return Month.type_to_s if Month.dates_valid?(start_date, end_date)
    return Quarter.type_to_s if Quarter.dates_valid?(start_date, end_date)
    return Year.type_to_s if Year.dates_valid?(start_date, end_date)

    nil
  end

  private

  def validate_has_no_duplicates
    if has_duplicate?
      errors.add(:base, 'has same attributes as another priority connection')
    end
  end

  def has_duplicate?
    PriorityConnection
    .where(
      priority_connectable: priority_connectable,
      priority: priority,
      direct: direct,
      start_date: start_date,
      end_date: end_date)
    .where.not(id: self)
    .exists?
  end
end
