module Amountable
  extend ActiveSupport::Concern

  module ClassMethods
    def average_amount
      calculate(:average, :amount)
    end
  end
end
