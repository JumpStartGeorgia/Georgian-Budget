require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_uploader').to_s

RSpec.describe 'BudgetUploader' do
  describe '#upload_folder' do
    it 'saves names of agencies and programs in files' do
      # setup
      monthly_budgets_start_date = Date.new(2015, 01, 01)
      I18n.locale = 'ka'
      test_budget_files_dir = Rails.root.join(
        'budget_files',
        'repo',
        'files',
        'monthly_spreadsheets',
        '2015'
      )

      # exercise
      uploader = BudgetUploader.new
      uploader.upload(
        monthly_paths: [
          test_budget_files_dir.join('monthly_spreadsheet-01.2015.xlsx').to_s,
          test_budget_files_dir.join('monthly_spreadsheet-02.2015.xlsx').to_s
        ]
      )

      # verify
      # TOTAL
      total = Total.first

      expect(total.code).to eq('00')

      expect(total.name_en).to eq('Total Georgian Budget')
      expect(total.name_ka).to eq('მთლიანი სახელმწიფო ბიუჯეტი')

      # Total: spent
      total_spent_finance1 = total.spent_finances[0]
      total_spent_finance2 = total.spent_finances[1]

      expect(total.spent_finances.length).to eq(2)

      expect(total_spent_finance1.amount.to_f).to eq(656549486.69)
      expect(total_spent_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(total_spent_finance1.end_date).to eq(Date.new(2015, 1, 31))

      expect(total_spent_finance2.amount.to_f).to eq(641341973.31)
      expect(total_spent_finance2.start_date).to eq(Date.new(2015, 2, 1))
      expect(total_spent_finance2.end_date).to eq(Date.new(2015, 2, 28))

      # Total: planned
      total_planned_finances = total.all_planned_finances
      total_planned_finance1 = total_planned_finances[0]

      expect(total_planned_finances.length).to eq(1)

      expect(total_planned_finance1.amount.to_f).to eq(2162575900)
      expect(total_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(total_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(total_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(total_planned_finance1.most_recently_announced).to eq(true)

      ### SPENDING AGENCY 1
      spending_agency1_array = SpendingAgency.find_by_name('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
      spending_agency1 = spending_agency1_array[0]

      expect(spending_agency1_array.length).to eq(1)
      expect(spending_agency1.code).to eq('01 00')
      expect(spending_agency1.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      # agency1: spent
      spending_agency1_spent_finance1 = spending_agency1.spent_finances[0]
      spending_agency1_spent_finance2 = spending_agency1.spent_finances[1]

      expect(spending_agency1.spent_finances.length).to eq(2)

      expect(spending_agency1_spent_finance1.amount.to_f).to eq(3532432.91)
      expect(spending_agency1_spent_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_spent_finance1.end_date).to eq(Date.new(2015, 1, 31))

      expect(spending_agency1_spent_finance2.amount.to_f).to eq(3753083.38)
      expect(spending_agency1_spent_finance2.start_date).to eq(Date.new(2015, 2, 1))
      expect(spending_agency1_spent_finance2.end_date).to eq(Date.new(2015, 2, 28))

      # agency1: planned
      spending_agency1_planned_finances = spending_agency1.all_planned_finances
      spending_agency1_planned_finance1 = spending_agency1_planned_finances[0]

      expect(spending_agency1_planned_finances.length).to eq(1)

      expect(spending_agency1_planned_finance1.amount.to_f).to eq(14767400)
      expect(spending_agency1_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency1_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_planned_finance1.most_recently_announced).to eq(true)

      ### SPENDING AGENCY
      spending_agency2_array = SpendingAgency.find_by_name('საქართველოს მთავრობის ადმინისტრაცია')
      spending_agency2 = spending_agency2_array[0]

      expect(spending_agency2_array.length).to eq(1)
      expect(spending_agency2.code).to eq('04 00')
      expect(spending_agency2.name).to eq('საქართველოს მთავრობის ადმინისტრაცია')

      # this spending agency changes plans from january to february, so it
      # has two plans for the same quarter
      spending_agency2_planned_finances = spending_agency2.all_planned_finances
      spending_agency2_planned_finance1 = spending_agency2_planned_finances[0]
      spending_agency2_planned_finance2 = spending_agency2_planned_finances[1]

      expect(spending_agency2_planned_finance1.amount.to_f).to eq(11471000)
      expect(spending_agency2_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency2_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance1.most_recently_announced).to eq(false)

      expect(spending_agency2_planned_finance2.amount.to_f).to eq(12471000)
      expect(spending_agency2_planned_finance2.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance2.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency2_planned_finance2.announce_date).to eq(Date.new(2015, 2, 1))
      expect(spending_agency2_planned_finance2.most_recently_announced).to eq(true)

      # TODO
      ### PROGRAM
      program1_array = Program.find_by_name('საკანონმდებლო საქმიანობა')
      program1 = program1_array[0]

      expect(program1_array.length).to eq(1)
      expect(program1.code).to eq('01 01')
      expect(program1.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      spending_agency2_array = SpendingAgency.find_by_name('საქართველოს პრეზიდენტის ადმინისტრაცია')
      spending_agency2 = spending_agency2_array[0]

      expect(spending_agency2_array.length).to eq(1)
      expect(spending_agency2.code).to eq('02 00')
      expect(spending_agency2.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      program2_array = Program.find_by_name('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')
      program2 = program2_array[0]

      expect(program2_array.length).to eq(1)
      expect(program2.code).to eq('03 01')
      expect(program2.recent_name_object.start_date).to eq(monthly_budgets_start_date)
    end
  end
end
