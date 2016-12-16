class PriorityConnection < ApplicationRecord
  include StartEndDateable
  
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
