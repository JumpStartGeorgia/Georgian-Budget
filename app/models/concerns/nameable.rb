module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, as: :nameable
  end

  def name
    names.order('start_date').last.text
  end
end
