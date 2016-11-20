class YearlyBudgetSheet::Item
  def initialize(args = {})
    @header_row_data = args[:header_row_data]
    @header_row_values = args[:header_row_values]
  end

  def has_valid_header_row_data?
    value_is_only_number_and_string?(header_row_values[1])
  end

  def code_number
    header_row_values[1]
  end

  def name_ka
    header_row_values[2]
  end

  def two_years_earlier_spent_amount
    amount = header_row_values[3]
    amount.present? ? amount * amount_multiplier : nil
  end

  def previous_year_plan_amount
    amount = header_row_values[4]
    amount.present? ? amount * amount_multiplier : nil
  end

  def current_year_plan_amount
    amount = header_row_values[5]
    amount.present? ? amount * amount_multiplier : nil
  end

  def header_row_values
    @header_row_values ||= get_header_row_values
  end

  attr_reader :header_row_data

  private

  def value_is_only_number_and_string?(value)
    return false if value.blank?
    return false if (value =~ /[^\d\s]/).present?

    true
  end

  def get_header_row_values
    header_row_data.cells.map do |cell|
      value = cell.present? ? cell.value : nil
      value.present? ? value : nil
    end
  end

  # amounts in yearly spreadsheets are recorded in 1000s
  def amount_multiplier
    1000
  end
end
