class PrimaryFinancesCSVExporter
  attr_reader :time_period_type, :locale

  def initialize(time_period_type, locale)
    @time_period_type = time_period_type
    @locale = locale
    unless possible_time_period_types.include?(time_period_type)
      raise "Unallowed time period type: #{time_period_type}. Possible time period types are: #{possible_time_period_types.join(', ')}"
    end
  end

  def export
    I18n.with_locale locale do
      CSV.open(csv_file_path, 'wb') do |csv|
        rows.each { |row| csv << row }
      end
    end
  end

  private

  def possible_time_period_types
    ['monthly', 'quarterly', 'yearly']
  end

  def rows
    [headers] + content_rows
  end

  def csv_file_path
    Rails.root.join('tmp', file_name)
  end

  def file_name
    "primary_finances_#{time_period_type}.csv"
  end

  def headers
    [
      'Type',
      'Name',
      'Code'
    ] + time_period_headers
  end

  def time_period_headers
    uniq_time_period_strings
  end

  def content_rows
    rows_for_budget_item_type(Total) +
      rows_for_budget_item_type(Priority)
  end

  def rows_for_budget_item_type(type_klass)
    type_klass.all.map { |item| values_for(item) }
  end

  def values_for(item)
    [
      item.class.to_s,
      item.name,
      item.respond_to?(:code) ? item.code : 'N/A'
    ] + finances_for(item)
  end

  def finances_for(item)
    uniq_time_period_strings.map do |time_period_string|
      item.spent_finances.find { |f| f.time_period == time_period_string }.amount
    end
  end

  def uniq_time_period_strings
    @uniq_time_period_strings ||= all_time_period_strings.uniq
  end

  def all_time_period_strings
    distinct_time_periods_for_finance(SpentFinance) +
      distinct_time_periods_for_finance(PlannedFinance)
  end

  def distinct_time_periods_for_finance(finance_class)
    finance_class
    .select(:time_period, :start_date)
    .send(time_period_type)
    .order(:start_date)
    .group(:time_period, :start_date)
    .pluck(:time_period)
  end
end
