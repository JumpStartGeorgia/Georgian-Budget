module BudgetCodeMapper
  def self.class_for_code(code)
    if code === '00'
      return Total
    elsif code.length == 5 && code.split(//).last(2).join == '00'
      return SpendingAgency
    elsif code.length >= 5 && code.length % 3 == 2
      return Program
    end
  end
end
