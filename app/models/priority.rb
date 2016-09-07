class Priority < ApplicationRecord
  has_many :names, as: :nameable
  
  def name
    names.order('start_date').last.text
  end
end
