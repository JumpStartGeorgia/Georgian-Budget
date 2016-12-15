class AmountFormatter
  attr_reader :amount

  def initialize(amount)
    @amount = amount
  end

  def remove_decimals
    return AmountFormatter.new(nil) if amount.nil?
    AmountFormatter.new(amount.to_i)
  end

  def to_s_with_commas
    return nil if amount.nil?

    ActionController::Base.helpers
    .number_with_delimiter(amount, delimiter: ',')
  end
end
