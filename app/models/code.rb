class Code < ApplicationRecord
  belongs_to :codeable, polymorphic: true

  validates :start_date, presence: true
  validates :number, presence: true
  validates :codeable, presence: true

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
