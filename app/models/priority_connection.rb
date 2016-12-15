class PriorityConnection < ApplicationRecord
  belongs_to :priority
  belongs_to :priority_connectable, polymorphic: true

  validates_with StartEndDateValidator
  validates :priority, presence: true
  validates :priority_connectable, presence: true
  validates :direct, inclusion: { in: [true, false] }

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
end
