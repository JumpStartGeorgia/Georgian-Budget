module BudgetCodeMapper
  def self.class_for_code(code)
    code_split = code.split(' ')

    if code == '00' || code == '00 00'
      return Total
    elsif code_split.length == 1
      return Priority
    elsif code_split.length == 2 && code_split.last == '00'
      return SpendingAgency
    elsif code_split.length >= 2
      return Program
    else
      raise "Could not determine the class for code #{code}"
    end
  end
end
