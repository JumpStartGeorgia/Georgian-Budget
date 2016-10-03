require 'rails_helper'

RSpec.describe MonthlyBudgetSheet::File do
  it 'gets the right values for August, 2014' do
    total = FactoryGirl.create(:total)

    FactoryGirl.create(
      :spent_finance,
      amount: 4714720298.3,
      start_date: Date.new(2014, 7, 1),
      end_date: Date.new(2014, 7, 1).end_of_month,
      finance_spendable: total
    )

    august_2014_sheet = Rails.root.join(
      'budget_files',
      'repo',
      'files',
      'monthly_spreadsheets',
      '2014',
      'monthly_spreadsheet-08.2014.xlsx'
    ).to_s

    MonthlyBudgetSheet::File.new(august_2014_sheet).save_data

    total.reload

    expect(total.spent_finances.last.amount.to_f).to eq(637285988.22)
  end
end
