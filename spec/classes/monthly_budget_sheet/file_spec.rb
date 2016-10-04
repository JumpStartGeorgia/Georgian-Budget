require 'rails_helper'

RSpec.describe MonthlyBudgetSheet::File do
  let(:total) { FactoryGirl.create(:total, code: '00') }

  it 'gets the right values for August, 2014' do
    FactoryGirl.create(
      :spent_finance,
      amount: 4714720298.3,
      start_date: Date.new(2014, 7, 1),
      end_date: Date.new(2014, 7, 1).end_of_month,
      finance_spendable: total
    )

    september_2014_sheet = Rails.root.join(
      'budget_files',
      'repo',
      'files',
      'monthly_spreadsheets',
      '2014',
      'monthly_spreadsheet-08.2014.xlsx'
    ).to_s

    MonthlyBudgetSheet::File.new(september_2014_sheet).save_data

    total.reload

    expect(total.spent_finances.last.amount.to_f).to eq(637285988.22)
  end

  it 'gets the right values for September, 2014' do
    FactoryGirl.create(
      :spent_finance,
      amount: 5352006286.52,
      start_date: Date.new(2014, 8, 1),
      end_date: Date.new(2014, 8, 1).end_of_month,
      finance_spendable: total
    )

    total.add_planned_finance(
      amount: 4354890200,
      time_period: Quarter.for_date(Date.new(2014, 4, 1)),
      announce_date: Date.new(2014, 6, 1)
    )

    september_2014_sheet = Rails.root.join(
      'budget_files',
      'repo',
      'files',
      'monthly_spreadsheets',
      '2014',
      'monthly_spreadsheet-09.2014.xlsx'
    ).to_s

    MonthlyBudgetSheet::File.new(september_2014_sheet).save_data

    total.reload
    expect(total.spent_finances.last.amount.to_f).to eq(830795862.26)
    expect(total.planned_finances.last.amount.to_f).to eq(6747604300 - 4354890200)

    agency = SpendingAgency.find_by_code('01 00')
    expect(agency.name_ka).to eq('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
  end
end
