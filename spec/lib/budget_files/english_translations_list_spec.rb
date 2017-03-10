require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload' do
    before :example do
      I18n.locale = 'ka'
    end

    context 'with english translations list' do
      before :context do
        start_date_2015_jan_1 = Date.new(2015, 1, 1)

        @priority = FactoryGirl.create(
          :priority
        ).add_name(
          text_ka: 'უკატეგორიო',
          start_date: start_date_2015_jan_1
        )

        @spending_agency = FactoryGirl.create(
          :spending_agency
        ).add_code(
          number: '35 00',
          start_date: start_date_2015_jan_1
        ).add_name(
          text_ka: 'საქართველოს შრომის, ჯანმრთელობისა და სოციალური დაცვის სამინისტრო',
          start_date: start_date_2015_jan_1
        )

        @program = FactoryGirl.create(
          :program
        ).add_code(
          number: '23 01',
          start_date: start_date_2015_jan_1
        ).add_name(
          text_ka: 'სახელმწიფო ფინანსების მართვა',
          start_date: start_date_2015_jan_1
        )

        @long_dash_agency = FactoryGirl.create(
          :spending_agency
        ).add_name(
          text_ka: 'სახელმწიფო რწმუნებულის – გუბერნატორის ადმინისტრაცია აბაშის, ზუგდიდის, მარტვილის, მესტიის, სენაკის, ჩხოროწყუს, წალენჯიხის, ხობის მუნიციპალიტეტებსა და თვითმმართველ ქალაქ ფოთში',
          start_date: start_date_2015_jan_1
        )

        BudgetFiles.new(
          budget_item_translations: BudgetFiles.english_translations_file
        ).upload
      end

      after :context do
        Deleter.delete_all_budget_data
      end

      it 'saves English translation of priority' do
        expect(@priority.name_en).to eq('Uncategorized')
      end

      it 'saves English translation of spending agency' do
        expect(@spending_agency.name_en).to eq(
          'Ministry Of Labour Health and Social Affairs Georgia')
      end

      it 'saves English translation of program' do
        expect(@program.name_en).to eq('Public Funds Management')
      end

      it 'saves English translation of program with long dash that is listed in CSV as -' do
        expect(@long_dash_agency.name_en).to eq('Administration of the State Representative – Governor in ABASHA, ZUGDIDI, MARTVILI, MESTIA, SENAKI, CHKHOROTSKU, TSALENJIKHA, KHOBI Municipalities and the Local Self-Governing City of POTI')
      end
    end
  end
end
