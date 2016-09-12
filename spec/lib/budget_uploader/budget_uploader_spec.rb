require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_uploader').to_s

RSpec.describe 'BudgetUploader' do
  describe '#upload_folder' do
    it 'saves names of agencies and programs in files' do
      # setup
      monthly_budgets_start_date = Date.new(2015, 01, 01)
      I18n.locale = 'ka'
      test_budget_files_dir = Rails.root.join('spec', 'test_data', 'budget_files').to_s

      # exercise
      uploader = BudgetUploader.new
      uploader.upload_folder(test_budget_files_dir)

      # verify
      spending_agency1_array = SpendingAgency.find_by_name('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
      spending_agency1 = spending_agency1_array[0]

      expect(spending_agency1_array.length).to eq(1)
      expect(spending_agency1.name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      program1_array = Program.find_by_name('საკანონმდებლო საქმიანობა')
      program1 = program1_array[0]

      expect(program1_array.length).to eq(1)
      expect(program1.name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      spending_agency2_array = SpendingAgency.find_by_name('საქართველოს პრეზიდენტის ადმინისტრაცია')
      spending_agency2 = spending_agency2_array[0]

      expect(spending_agency2_array.length).to eq(1)
      expect(spending_agency2.name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      program2_array = Program.find_by_name('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')
      program2 = program2_array[0]

      expect(program2_array.length).to eq(1)
      expect(program2.name_object.start_date).to eq(monthly_budgets_start_date)
    end
  end
end
