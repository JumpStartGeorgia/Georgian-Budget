require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_uploader').to_s

RSpec.describe 'BudgetUploader' do
  describe '#upload_folder' do
    it 'saves names of agencies and programs in files' do
      # setup
      I18n.locale = 'ka'
      test_budget_files_dir = Rails.root.join('spec', 'test_data', 'budget_files').to_s
      uploader = BudgetUploader.new
      uploader.upload_folder(test_budget_files_dir)

      # exercise
      spending_agency1 = SpendingAgency.find_by_name('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
      program1 = Program.find_by_name('საკანონმდებლო საქმიანობა')

      spending_agency2 = SpendingAgency.find_by_name('საქართველოს პრეზიდენტის ადმინისტრაცია')
      program2 = Program.find_by_name('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')

      # verify
      expect(spending_agency1.length).to eq(1)
      expect(program1.length).to eq(1)

      expect(spending_agency2.length).to eq(1)
      expect(program2.length).to eq(1)
    end
  end
end
