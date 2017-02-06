class Code < ApplicationRecord
  belongs_to :codeable, polymorphic: true

  validates :start_date, presence: true
  validates :number, presence: true
  validates :codeable, presence: true

  # generation refers to how far you have to zoom into the budget
  # to find the item with this code. Examples:
  # spending agencies: 1
  # top-level programs: 2
  # subprograms of top-level programs: 3
  def generation
    return 1 if represents_spending_agency?

    number_parts.count
  end

  def number_parts
    number.split(' ')
  end

  def represents_spending_agency?
    number_parts.count == 2 && number_parts[1] == '00'
  end
end
