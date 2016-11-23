namespace :budget_data do
  desc 'Export CSV of official and unofficial yearly spent finances'
  task export_yearly_spent_finances: :environment do
    I18n.locale = 'ka'

    file_name = "yearly_spent_finances.csv"
    csv_file_path = Rails.root.join('tmp', file_name)

    year_2012 = Year.new(2012)
    year_2013 = Year.new(2013)
    year_2014 = Year.new(2014)
    year_2015 = Year.new(2015)
    year_2016 = Year.new(2016)

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
        '2012 unofficial',
        '2012 diff',
        '2012 bigger amount',
        '2013 official',
        '2013 unofficial',
        '2013 diff',
        '2013 bigger amount',
        '2014 official',
        '2014 unofficial',
        '2014 diff',
        '2014 bigger amount',
        '2015 unofficial',
        '2016 unofficial'
      ]

      budget_items.each do |budget_item|
        puts 'Outputting budget item'
        spent_finances = budget_item.spent_finances

        official_2012 = official_amount(spent_finances, year_2012)
        unofficial_2012 = unofficial_amount(spent_finances, year_2012)
        official_2013 = official_amount(spent_finances, year_2013)
        unofficial_2013 = unofficial_amount(spent_finances, year_2013)
        official_2014 = official_amount(spent_finances, year_2014)
        unofficial_2014 = unofficial_amount(spent_finances, year_2014)
        unofficial_2015 = unofficial_amount(spent_finances, year_2015)
        unofficial_2016 = unofficial_amount(spent_finances, year_2016)

        csv << [
          budget_item.class,
          budget_item.code,
          budget_item.name,
          *year_columns(official_2012, unofficial_2012),
          *year_columns(official_2013, unofficial_2013),
          *year_columns(official_2014, unofficial_2014),
          unofficial_2015,
          unofficial_2016
        ]
      end
    end
  end

  def year_columns(official, unofficial)
    [
      official,
      unofficial,
      difference(official, unofficial),
      difference_text(official, unofficial)
    ]
  end

  def official_amount(spent_finances, year)
    finance = spent_finances.find { |finance| finance.time_period == year && finance.official }
    return 'No Value' unless finance.present?
    return 'Missing Value' unless finance.amount.present?

    finance.amount
  end

  def unofficial_amount(spent_finances, year)
    finance = spent_finances.find { |finance| finance.time_period == year && !finance.official }

    return 'No Value' unless finance.present?
    return 'Missing Value' unless finance.amount.present?

    finance.amount
  end

  def difference(official, unofficial)
    return 'N/A' unless official.is_a? Numeric
    return 'N/A' unless unofficial.is_a? Numeric

    (official - unofficial).abs
  end

  def difference_text(official, unofficial)
    return 'N/A' unless official.is_a? Numeric
    return 'N/A' unless unofficial.is_a? Numeric

    official > unofficial ? 'Official bigger' : official < unofficial ? 'Unofficial bigger' : 'No difference'
  end
end