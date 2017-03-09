namespace :budget_data do
  desc 'Export CSV of official and monthly_sum yearly spent finances'
  task export_yearly_spent_finances: :environment do
    I18n.locale = 'ka'

    file_name = "yearly_spent_finances.csv"
    csv_file_path = Rails.root.join('tmp', file_name)

    totals = Total.all
    spending_agencies = SpendingAgency.all.with_spent_finances.merge(SpentFinance.yearly).with_most_recent_names.order(:code)
    programs = Program.all.with_spent_finances.merge(SpentFinance.yearly).with_most_recent_names.order(:code)

    budget_items = totals + spending_agencies + programs

    require 'csv'
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << [
        'Type',
        'Code',
        'Name',
        '2012 official',
        '2012 monthly_sums',
        '2012 diff',
        '2012 bigger amount',
        '2013 official',
        '2013 monthly_sums',
        '2013 diff',
        '2013 bigger amount',
        '2014 official',
        '2014 monthly_sums',
        '2014 diff',
        '2014 bigger amount',
        '2015 monthly_sums',
        '2016 monthly_sums'
      ]

      budget_items.each do |budget_item|
        spent_finances = budget_item.spent_finances

        official_2012 = official_amount(spent_finances, Year.new(2012))
        monthly_sum_2012 = monthly_sum_amount(spent_finances, Year.new(2012))
        official_2013 = official_amount(spent_finances, Year.new(2013))
        monthly_sum_2013 = monthly_sum_amount(spent_finances, Year.new(2013))
        official_2014 = official_amount(spent_finances, Year.new(2014))
        monthly_sum_2014 = monthly_sum_amount(spent_finances, Year.new(2014))
        monthly_sum_2015 = monthly_sum_amount(spent_finances, Year.new(2015))
        monthly_sum_2016 = monthly_sum_amount(spent_finances, Year.new(2016))

        csv << [
          budget_item.class,
          budget_item.code,
          budget_item.name,
          *year_columns(official_2012, monthly_sum_2012),
          *year_columns(official_2013, monthly_sum_2013),
          *year_columns(official_2014, monthly_sum_2014),
          monthly_sum_2015,
          monthly_sum_2016
        ]
      end
    end
  end

  def year_columns(official, monthly_sum)
    [
      official,
      monthly_sum,
      difference(official, monthly_sum),
      difference_text(official, monthly_sum)
    ]
  end

  def official_amount(spent_finances, year)
    finance = spent_finances.find { |finance| finance.time_period == year.to_s && finance.official }
    return 'No Value' unless finance.present?
    return 'Nil Value' unless finance.amount.present?

    finance.amount
  end

  def monthly_sum_amount(spent_finances, year)
    monthly_finances_in_year = spent_finances
    .monthly
    .official
    .within_time_period(year)

    return 'No Monthly Finances' unless monthly_finances_in_year.present?
    return monthly_finances_in_year.sum(:amount)
  end

  def difference(official, monthly_sum)
    return 'N/A' unless official.is_a? Numeric
    return 'N/A' unless monthly_sum.is_a? Numeric

    (official - monthly_sum).abs
  end

  def difference_text(official, monthly_sum)
    return 'N/A' unless official.is_a? Numeric
    return 'N/A' unless monthly_sum.is_a? Numeric

    official > monthly_sum ? 'Official bigger' : official < monthly_sum ? 'Unofficial bigger' : 'No difference'
  end
end
