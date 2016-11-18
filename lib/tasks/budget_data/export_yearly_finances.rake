namespace :budget_data do
  desc 'Export CSV of official and unofficial yearly spent finances'
  task export_yearly_spent_finances: :environment do
    I18n.locale = 'ka'

    file_name = "yearly_spent_finances.csv"
    csv_file_path = Rails.root.join('tmp', file_name)

    require 'csv'
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << [
        'Type',
        'Item Name',
        '2012 official',
        '2012 unofficial',
        '2013 official',
        '2013 unofficial',
        '2014 official',
        '2014 unofficial',
        '2015 unofficial',
        '2016 unofficial'
      ]

      year_2012 = Year.new(2012)
      year_2013 = Year.new(2013)
      year_2014 = Year.new(2014)
      year_2015 = Year.new(2015)
      year_2016 = Year.new(2016)

      totals = Total.all
      spending_agencies = SpendingAgency.all.with_spent_finances.merge(SpentFinance.yearly).with_most_recent_names
      programs = Program.all.with_spent_finances.merge(SpentFinance.yearly).with_most_recent_names

      budget_items = totals + spending_agencies + programs

      budget_items.each do |budget_item|
        spent_finances = budget_item.spent_finances

        csv << [
          budget_item.class,
          budget_item.name,
          official_amount(spent_finances, year_2012),
          unofficial_amount(spent_finances, year_2012),
          official_amount(spent_finances, year_2013),
          unofficial_amount(spent_finances, year_2013),
          official_amount(spent_finances, year_2014),
          unofficial_amount(spent_finances, year_2014),
          unofficial_amount(spent_finances, year_2015),
          unofficial_amount(spent_finances, year_2016)
        ]
      end
    end
  end

  def official_amount(spent_finances, year)
    finance = spent_finances.find { |finance| finance.time_period == year && finance.official }
    finance.present? ? finance.amount_pretty : ''
  end

  def unofficial_amount(spent_finances, year)
    finance = spent_finances.find { |finance| finance.time_period == year && !finance.official }
    finance.present? ? finance.amount_pretty : ''
  end
end
