class YearlyBudgetSheet::Item
  def initialize(args = {})
    @header_row_data = args[:header_row_data]
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
    header_row_values[3] * amount_multiplier
  end

  def previous_year_plan_amount
    header_row_values[4] * amount_multiplier
  end

  def current_year_plan_amount
    header_row_values[5] * amount_multiplier
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
      cell.present? && cell.value.present? ? cell.value : nil
    end
  end

  # amounts in yearly spreadsheets are recorded in 1000s
  def amount_multiplier
    1000
  end
end
