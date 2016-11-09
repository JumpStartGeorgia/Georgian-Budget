require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload' do
    before :example do
      I18n.locale = 'ka'
    end

    context 'with monthly spreadsheets' do
      let(:monthly_budgets_start_date) { Date.new(2015, 01, 01) }

      before :context do
        month_files_dir = BudgetFiles.monthly_spreadsheet_dir.join('2015')

        # exercise
        BudgetFiles.new(
          monthly_paths: [
            month_files_dir.join('monthly_spreadsheet-01.2015.xlsx').to_s,
            month_files_dir.join('monthly_spreadsheet-02.2015.xlsx').to_s
          ],
          budget_item_translations: BudgetFiles.english_translations_file
        ).upload
      end

      after :context do
        [Program, SpendingAgency, Priority, Total].each(&:destroy_all)
      end

      context 'total:' do
        let(:total) { Total.first }
        let(:q1_2015) { Quarter.for_date(Date.new(2015, 1, 1)) }

        it 'saves total code' do
          expect(total.code).to eq('00')
        end

        it 'saves total start date' do
          expect(total.start_date).to eq(q1_2015.start_date)
        end

        it 'saves total end date' do
          expect(total.end_date).to eq(q1_2015.end_date)
        end

        it 'saves total English name' do
          expect(total.name_en).to eq('Complete National Budget')
        end

        it 'saves total Georgian name' do
          expect(total.name_ka).to eq('მთლიანი სახელმწიფო ბიუჯეტი')
        end

        context 'spent finances:' do
          it 'saves correct number of monthly spent finances' do
            expect(total.spent_finances.monthly.length).to eq(2)
          end

          it 'saves january spent finance' do
            finance = total.spent_finances.monthly[0]
            expect(finance.amount.to_f).to eq(656549486.69)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 1, 31))
          end

          it 'saves february spent finance' do
            finance = total.spent_finances.monthly[1]
            expect(finance.amount.to_f).to eq(641341973.31)
            expect(finance.start_date).to eq(Date.new(2015, 2, 1))
            expect(finance.end_date).to eq(Date.new(2015, 2, 28))
          end

          it 'saves correct number of quarterly spent finances' do
            expect(total.spent_finances.quarterly.length).to eq(1)
          end

          it 'saves quarterly spent finance' do
            finance = total.spent_finances.quarterly[0]

            expect(finance.amount.to_f).to eq(656549486.69 + 641341973.31)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
          end
        end

        context 'planned finances:' do
          it 'saves first planned finance' do
            finance = total.all_planned_finances[0]

            expect(finance.amount.to_f).to eq(2162575900)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
            expect(finance.announce_date).to eq(Date.new(2015, 1, 1))
            expect(finance.most_recently_announced).to eq(true)
          end

          it 'saves correct number of planned finances' do
            expect(total.all_planned_finances.length).to eq(1)
          end
        end
      end

      context 'spending agency (parliament):' do
        let(:spending_agency1_array) do
          SpendingAgency.find_by_name('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
        end

        let(:spending_agency1) { spending_agency1_array[0] }

        it 'saves only one' do
          expect(spending_agency1_array.length).to eq(1)
        end

        it 'saves correct code' do
          expect(spending_agency1.code).to eq('01 00')
        end

        it 'saves correct start date of name' do
          expect(spending_agency1.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end

        context 'spent finances:' do
          it 'saves correct number of monthly spent finances' do
            expect(spending_agency1.spent_finances.monthly.length).to eq(2)
          end

          it 'saves January spent finance' do
            finance = spending_agency1.spent_finances.monthly[0]
            expect(finance.amount.to_f).to eq(3532432.91)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 1, 31))
          end

          it 'saves February spent finance' do
            finance = spending_agency1.spent_finances.monthly[1]

            expect(finance.amount.to_f).to eq(3753083.38)
            expect(finance.start_date).to eq(Date.new(2015, 2, 1))
            expect(finance.end_date).to eq(Date.new(2015, 2, 28))
          end

          it 'saves correct number of quarterly spent finances' do
            expect(spending_agency1.spent_finances.quarterly.length).to eq(1)
          end

          it 'saves quarter 1 spent finance' do
            finance = spending_agency1.spent_finances.quarterly[0]

            expect(finance.amount.to_f).to eq(3532432.91 + 3753083.38)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
          end
        end

        context 'planned finances:' do
          it 'saves correct number of planned finances' do
            expect(spending_agency1.all_planned_finances.length).to eq(1)
          end

          it 'saves first planned finance' do
            spending_agency1_planned_finance1 = spending_agency1.all_planned_finances[0]

            expect(spending_agency1_planned_finance1.amount.to_f).to eq(14767400)
            expect(spending_agency1_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
            expect(spending_agency1_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
            expect(spending_agency1_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
            expect(spending_agency1_planned_finance1.most_recently_announced).to eq(true)
          end
        end
      end

      context 'spending agency (government administration):' do
        let(:spending_agency2_array) do
          SpendingAgency.find_by_name('საქართველოს მთავრობის ადმინისტრაცია')
        end

        let(:spending_agency2) { spending_agency2_array[0] }

        it 'saves only one' do
          expect(spending_agency2_array.length).to eq(1)
        end

        it 'saves code' do
          expect(spending_agency2.code).to eq('04 00')
        end

        context 'planned finances:' do
          # this spending agency changes plans from january to february, so it
          # has two plans for the same quarter

          it 'saves first planned finance' do
            spending_agency2_planned_finance1 = spending_agency2.all_planned_finances[0]

            expect(spending_agency2_planned_finance1.amount.to_f).to eq(11471000)
            expect(spending_agency2_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
            expect(spending_agency2_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
            expect(spending_agency2_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
            expect(spending_agency2_planned_finance1.most_recently_announced).to eq(false)
          end

          it 'saves second planned finance' do
            spending_agency2_planned_finance2 = spending_agency2.all_planned_finances[1]

            expect(spending_agency2_planned_finance2.amount.to_f).to eq(12471000)
            expect(spending_agency2_planned_finance2.start_date).to eq(Date.new(2015, 1, 1))
            expect(spending_agency2_planned_finance2.end_date).to eq(Date.new(2015, 3, 31))
            expect(spending_agency2_planned_finance2.announce_date).to eq(Date.new(2015, 2, 1))
            expect(spending_agency2_planned_finance2.most_recently_announced).to eq(true)
          end
        end
      end

      context 'spending agency (president administration):' do
        let(:spending_agency2_array) do
          SpendingAgency.find_by_name('საქართველოს პრეზიდენტის ადმინისტრაცია')
        end

        let(:spending_agency2) { spending_agency2_array[0] }

        it 'saves only one' do
          expect(spending_agency2_array.length).to eq(1)
        end

        it 'saves code' do
          expect(spending_agency2.code).to eq('02 00')
        end

        it 'saves correct start date for name' do
          expect(spending_agency2.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end

      context 'program (legislation):' do
        let(:program1_array) do
          Program.find_by_name('საკანონმდებლო საქმიანობა')
        end

        let(:program1) { program1_array[0] }

        it 'saves only one' do
          expect(program1_array.length).to eq(1)
        end

        it 'saves code' do
          expect(program1.code).to eq('01 01')
        end

        it 'saves correct start date of name' do
          expect(program1.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end

      context 'program (security and internal affairs apparatus):' do
        let(:program2_array) do
          Program.find_by_name('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')
        end

        let(:program2) { program2_array[0] }

        it 'saves only one' do
          expect(program2_array.length).to eq(1)
        end

        it 'saves code' do
          expect(program2.code).to eq('03 01')
        end

        it 'saves correct start date for name' do
          expect(program2.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end
    end

    context 'with priorities list and priority associations list' do
      before :context do
        @january_2012 = Month.for_date(Date.new(2012, 1, 1))
        @quarter1_2012 = Quarter.for_date(Date.new(2012, 1, 1))
        # Setup parliament agency
        @parliament = SpendingAgency.create(code: '01 00')
        @parliament.add_name(
          text_ka: 'საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები',
          start_date: Date.new(2012, 1, 1)
        )

        # Setup audit regulation program
        @audit_regulation_program = Program.create(code: '01 02')
        @audit_regulation_program.add_name(
          text_ka: 'აუდიტორული საქმიანობის სახელმწიფო რეგულირება',
          start_date: Date.new(2012, 1, 1)
        )

        # Setup library program
        @library_program = Program.create(code: '01 02')
        @library_program.add_name(
          text_ka: 'საბიბლიოთეკო საქმიანობა',
          start_date: Date.new(2013, 1, 1)
        )

        @library_program.add_spent_finance(
          time_period: @january_2012,
          amount: 30
        )

        @library_program.add_planned_finance(
          time_period: @quarter1_2012,
          announce_date: @quarter1_2012.start_date,
          amount: 300
        )

        @financier_qualifications_program = Program.create(code: '23 05')
        .add_name(
          text_ka: 'საფინანსო სექტორში დასაქმებულთა კვალიფიკაციის ამაღლება',
          start_date: Date.new(2012, 1, 1)
        ).add_spent_finance(
          time_period: @january_2012,
          amount: 70
        )

        @financier_qualifications_program.add_planned_finance(
          time_period: @quarter1_2012,
          announce_date: @quarter1_2012.start_date,
          amount: 200
        )

        # Exercise
        BudgetFiles.new(
          priorities_list: BudgetFiles.priorities_list,
          priority_associations_list: BudgetFiles.priority_associations_list
        ).upload
      end

      after :context do
        [Program, SpendingAgency, Priority, Total].each(&:destroy_all)
      end

      let(:uncategorized_priority) do
        Priority.find_by_name('უკატეგორიო')[0]
      end

      let(:economic_stability_priority) do
        Priority.find_by_name(
          'მაკროეკონომიკური სტაბილურობა და საინვესტიციო გარემოს გაუმჯობესება'
        )[0]
      end

      let(:education_priority) do
        Priority.find_by_name(
          'განათლება, მეცნიერება და პროფესიული მომზადება'
        )[0]
      end

      it 'creates uncategorized priority' do
        expect(uncategorized_priority).to_not eq(nil)

        expect(uncategorized_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'assigns parliament to uncategorized priority' do
        @parliament.reload
        expect(@parliament.priority).to eq(uncategorized_priority)
      end

      it 'creates economic stability priority' do
        expect(economic_stability_priority).to_not eq(nil)

        expect(economic_stability_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'assigns audit regulation program to economic stability priority' do
        @audit_regulation_program.reload
        expect(@audit_regulation_program.priority).to eq(economic_stability_priority)
      end

      it 'creates education priority' do
        expect(education_priority).to_not eq(nil)

        expect(education_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it "sets education priority's monthly spent finances" do
        monthly_spent_finances = education_priority.spent_finances.monthly

        expect(monthly_spent_finances.length).to eq(1)
        expect(monthly_spent_finances[0].amount).to eq(100)
        expect(monthly_spent_finances[0].time_period).to eq(@january_2012)
      end

      it "sets education priority's quarterly spent finances" do
        quarterly_spent_finances = education_priority.spent_finances.quarterly

        expect(quarterly_spent_finances.length).to eq(1)
        expect(quarterly_spent_finances[0].amount).to eq(100)
        expect(quarterly_spent_finances[0].time_period).to eq(
          Quarter.for_date(Date.new(2012, 1, 1)))
      end

      it "sets education priority's planned finances" do
        planned_finances = education_priority.planned_finances

        expect(planned_finances[0].amount).to eq(500)
        expect(planned_finances[0].time_period).to eq(@quarter1_2012)
      end

      it 'sets priority of library program' do
        @library_program.reload
        expect(@library_program.priority).to eq(education_priority)
      end

      it 'assigns financier_qualifications_program to education priority' do
        @financier_qualifications_program.reload
        expect(@financier_qualifications_program.priority).to eq(education_priority)
      end
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
        [Program, SpendingAgency, Priority, Total].each(&:destroy_all)
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
