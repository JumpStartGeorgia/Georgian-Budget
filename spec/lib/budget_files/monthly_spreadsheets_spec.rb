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
        Deleter.delete_all
      end

      context 'total:' do
        let(:total) { Total.first }
        let(:q1_2015) { Quarter.for_date(Date.new(2015, 1, 1)) }
        let(:year_2015) { Year.new(2015) }

        it 'saves total perma_id' do
          require 'digest/sha1'
          expect(total.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '00_მთლიანი_სახელმწიფო_ბიუჯეტი'
          )
        end

        it 'saves total code' do
          expect(total.code).to eq('00')
        end

        it 'saves total start date' do
          expect(total.start_date).to eq(year_2015.start_date)
        end

        it 'saves total end date' do
          expect(total.end_date).to eq(year_2015.end_date)
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
            expect(finance.time_period).to eq('y2015_m01')
            expect(finance.official).to eq(true)
          end

          it 'saves february spent finance' do
            finance = total.spent_finances.monthly[1]
            expect(finance.amount.to_f).to eq(641341973.31)
            expect(finance.start_date).to eq(Date.new(2015, 2, 1))
            expect(finance.end_date).to eq(Date.new(2015, 2, 28))
            expect(finance.time_period).to eq('y2015_m02')
            expect(finance.official).to eq(true)
          end

          it 'saves correct number of quarterly spent finances' do
            expect(total.spent_finances.quarterly.length).to eq(1)
          end

          it 'saves quarterly spent finance' do
            finance = total.spent_finances.quarterly[0]

            expect(finance.amount.to_f).to eq(656549486.69 + 641341973.31)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
            expect(finance.official).to eq(false)
          end

          it 'saves correct number of yearly spent finances' do
            expect(total.spent_finances.yearly.length).to eq(1)
          end

          it 'saves yearly spent finance' do
            finance = total.spent_finances.yearly[0]

            expect(finance.amount.to_f).to eq(656549486.69 + 641341973.31)
            expect(finance.official).to eq(false)
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
            expect(finance.official).to eq(true)
          end

          it 'saves correct number of planned finances' do
            expect(total.all_planned_finances.length).to eq(1)
          end
        end
      end

      context 'spending agency (parliament):' do
        let(:spending_agency1_array) do
          SpendingAgency.with_name_in_history('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
        end

        let(:spending_agency1) { spending_agency1_array[0] }

        it 'saves only one' do
          expect(spending_agency1_array.length).to eq(1)
        end

        it 'has three child programs' do
          expect(spending_agency1.child_programs.length).to eq(3)
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(spending_agency1.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '01_00_საქართველოს_პარლამენტი_და_მასთან_არსებული_ორგანიზაციები'
          )
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
            expect(finance.official).to eq(true)
          end

          it 'saves February spent finance' do
            finance = spending_agency1.spent_finances.monthly[1]

            expect(finance.amount.to_f).to eq(3753083.38)
            expect(finance.start_date).to eq(Date.new(2015, 2, 1))
            expect(finance.end_date).to eq(Date.new(2015, 2, 28))
            expect(finance.official).to eq(true)
          end

          it 'saves correct number of quarterly spent finances' do
            expect(spending_agency1.spent_finances.quarterly.length).to eq(1)
          end

          it 'saves quarter 1 spent finance' do
            finance = spending_agency1.spent_finances.quarterly[0]

            expect(finance.amount.to_f).to eq(3532432.91 + 3753083.38)
            expect(finance.official).to eq(false)
          end

          it 'saves correct number of yearly spent finances' do
            expect(spending_agency1.spent_finances.yearly.length).to eq(1)
          end

          it 'saves yearly spent finance' do
            finance = spending_agency1.spent_finances.yearly[0]

            expect(finance.amount.to_f).to eq(3532432.91 + 3753083.38)
            expect(finance.official).to eq(false)
          end
        end

        context 'planned finances:' do
          it 'saves correct number of planned finances' do
            expect(spending_agency1.all_planned_finances.length).to eq(1)
          end

          it 'saves first planned finance' do
            finance = spending_agency1.all_planned_finances[0]

            expect(finance.amount.to_f).to eq(14767400)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
            expect(finance.announce_date).to eq(Date.new(2015, 1, 1))
            expect(finance.most_recently_announced).to eq(true)
            expect(finance.official).to eq(true)
          end
        end
      end

      context 'spending agency (government administration):' do
        let(:spending_agency2_array) do
          SpendingAgency.with_name_in_history('საქართველოს მთავრობის ადმინისტრაცია')
        end

        let(:spending_agency2) { spending_agency2_array[0] }

        it 'saves only one' do
          expect(spending_agency2_array.length).to eq(1)
        end

        it 'saves code' do
          expect(spending_agency2.code).to eq('04 00')
        end

        it 'has no child programs' do
          expect(spending_agency2.child_programs.length).to eq(0)
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(spending_agency2.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '04_00_საქართველოს_მთავრობის_ადმინისტრაცია'
          )
        end

        context 'planned finances:' do
          # this spending agency changes plans from january to february, so it
          # has two plans for the same quarter

          it 'saves first planned finance' do
            finance = spending_agency2.all_planned_finances[0]

            expect(finance.amount.to_f).to eq(11471000)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
            expect(finance.announce_date).to eq(Date.new(2015, 1, 1))
            expect(finance.most_recently_announced).to eq(false)
            expect(finance.official).to eq(true)
          end

          it 'saves second planned finance' do
            finance = spending_agency2.all_planned_finances[1]

            expect(finance.amount.to_f).to eq(12471000)
            expect(finance.start_date).to eq(Date.new(2015, 1, 1))
            expect(finance.end_date).to eq(Date.new(2015, 3, 31))
            expect(finance.announce_date).to eq(Date.new(2015, 2, 1))
            expect(finance.most_recently_announced).to eq(true)
            expect(finance.official).to eq(true)
          end
        end
      end

      context 'spending agency (georgian economic ministry):' do
        let(:agency) do
          BudgetItem.find(name: 'საქართველოს ეკონომიკისა და მდგრადი განვითარების სამინისტრო', code: '24 00')
        end
        it 'saves 13 programs' do
          expect(agency.programs.length).to eq(13)
        end

        it 'saves 8 child programs' do
          expect(agency.child_programs.length).to eq(8)
        end
      end

      context 'spending agency (president administration):' do
        let(:spending_agency2_array) do
          SpendingAgency.with_name_in_history('საქართველოს პრეზიდენტის ადმინისტრაცია')
        end

        let(:spending_agency2) { spending_agency2_array[0] }

        it 'saves only one' do
          expect(spending_agency2_array.length).to eq(1)
        end

        it 'saves code' do
          expect(spending_agency2.code).to eq('02 00')
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(spending_agency2.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '02_00_საქართველოს_პრეზიდენტის_ადმინისტრაცია'
          )
        end

        it 'saves correct start date for name' do
          expect(spending_agency2.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end

      context 'program (legislation):' do
        let(:program1_array) do
          Program.with_name_in_history('საკანონმდებლო საქმიანობა')
        end

        let(:program1) { program1_array[0] }

        it 'saves only one' do
          expect(program1_array.length).to eq(1)
        end

        it 'saves code' do
          expect(program1.code).to eq('01 01')
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(program1.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '01_01_საკანონმდებლო_საქმიანობა'
          )
        end

        it 'saves agency' do
          expect(program1.spending_agency).to eq(SpendingAgency.find_by_code('01 00'))
        end

        it 'has no parent program' do
          expect(program1.parent_program).to eq(nil)
        end

        it 'saves correct start date of name' do
          expect(program1.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end

      context 'program (security and internal affairs apparatus):' do
        let(:program2_array) do
          Program.with_name_in_history('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')
        end

        let(:program2) { program2_array[0] }

        it 'saves only one' do
          expect(program2_array.length).to eq(1)
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(program2.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '03_01_საქართველოს_ეროვნული_უშიშროების_საბჭოს_აპარატი'
          )
        end

        it 'saves code' do
          expect(program2.code).to eq('03 01')
        end

        it 'saves agency' do
          expect(program2.spending_agency).to eq(SpendingAgency.find_by_code('03 00'))
        end

        it 'saves correct start date for name' do
          expect(program2.recent_name_object.start_date).to eq(monthly_budgets_start_date)
        end
      end

      context 'program (professional education)' do
        let(:program) do
          Program.find_by_code('32 03 01')
        end

        it 'saves agency' do
          expect(program.spending_agency).to eq(SpendingAgency.find_by_code('32 00'))
        end

        it 'saves parent program' do
          expect(program.parent_program).to eq(Program.find_by_code('32 03'))
        end

        it 'saves perma_id' do
          require 'digest/sha1'
          expect(program.perma_ids[0].text).to eq(
            Digest::SHA1.hexdigest '32_03_01_პროფესიული_განათლების_ხელმისაწვდომობის_და_ხარისხის_გაუმჯობესება'
          )
        end
      end
    end
  end
end
