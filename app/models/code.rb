class Code < ApplicationRecord
  belongs_to :codeable, polymorphic: true

  validates :start_date, presence: true
  validates :number, presence: true
  validates :codeable, presence: true
end
