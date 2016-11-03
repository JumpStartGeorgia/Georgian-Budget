require 'rails_helper'

describe MonthlyBudgetSheet::ItemSaver do
  describe '#save_data_from_monthly_sheet_item' do
    let(:monthly_sheet_item) do
      monthly_sheet_item = instance_double(
        MonthlyBudgetSheet::Item,
        'monthly_sheet_item'
      )
    end

    let(:previous_spent_finance_amount) { 1332 }
    let(:monthly_sheet_item_spent_finance_cumulative) { 11566 }

    let(:previous_planned_finance_amount) { 41 }
    let(:monthly_sheet_item_planned_finance_cumulative) { 32423 }

    before :example do
      allow(monthly_sheet_item).to receive(:spent_finance_cumulative)
      .and_return(monthly_sheet_item_spent_finance_cumulative)

      allow(monthly_sheet_item).to receive(:planned_finance_cumulative)
      .and_return(monthly_sheet_item_planned_finance_cumulative)
    end

    context 'when budget item is Total' do
      let(:total) { FactoryGirl.create(:total) }

      before :example do
        allow(monthly_sheet_item).to receive(:primary_code).and_return('00')
        allow(monthly_sheet_item).to receive(:name_text).and_return('ჯამური')
      end

      describe 'adds spent finance to total' do
        before :example do
          total.add_spent_finance(
            time_period: Month.for_date(Date.new(2012, 1, 1)),
            amount: previous_spent_finance_amount
          )
        end

        it '' do
          MonthlyBudgetSheet::ItemSaver.new(
            monthly_sheet_item,
            start_date: Date.new(2012, 2, 1)
          ).save_data_from_monthly_sheet_item

          expect(total.spent_finances.length).to eq(2)
        end

        it 'with correct amount' do
          MonthlyBudgetSheet::ItemSaver.new(
            monthly_sheet_item,
            start_date: Date.new(2012, 2, 1)
          ).save_data_from_monthly_sheet_item

          expect(total.spent_finances.last.amount).to eq(
            monthly_sheet_item_spent_finance_cumulative - previous_spent_finance_amount
          )
        end
      end

      describe 'adds planned finance to total' do
        before :example do
          total.add_planned_finance(
            time_period: Quarter.for_date(Date.new(2012, 1, 1)),
            announce_date: Date.new(2012, 1, 1),
            amount: previous_planned_finance_amount
          )
        end

        it '' do
          MonthlyBudgetSheet::ItemSaver.new(
            monthly_sheet_item,
            start_date: Date.new(2012, 4, 1)
          ).save_data_from_monthly_sheet_item

          expect(total.planned_finances.length).to eq(2)
        end

        it 'with correct amount' do
          MonthlyBudgetSheet::ItemSaver.new(
            monthly_sheet_item,
            start_date: Date.new(2012, 4, 1)
          ).save_data_from_monthly_sheet_item

          expect(total.planned_finances.last.amount).to eq(
            monthly_sheet_item_planned_finance_cumulative - previous_planned_finance_amount
          )
        end
      end
    end

    context 'when budget item is Program' do
      it 'saves cleaned name' do
        allow(monthly_sheet_item).to receive(:primary_code).and_return('01 01')

        allow(monthly_sheet_item).to receive(:name_text)
        .and_return('my  program')

        MonthlyBudgetSheet::ItemSaver.new(
          monthly_sheet_item,
          start_date: Date.new(2012, 4, 1)
        ).save_data_from_monthly_sheet_item

        new_program = Program.find_by_code('01 01')

        expect(new_program.name).to eq('my program')
      end

      context 'when previous program exists' do
        let(:previous_program) do
          FactoryGirl.create(:program)
          .add_spent_finance(
            time_period: Month.for_date(Date.new(2012, 1, 1)),
            amount: previous_spent_finance_amount
          ).add_planned_finance(
            time_period: Quarter.for_date(Date.new(2012, 1, 1)),
            announce_date: Date.new(2012, 1, 1),
            amount: previous_planned_finance_amount
          )
        end

        let(:current_program_code_number) { '01 01' }
        let(:current_program_name_text) { 'ჩემი პროგრამა' }

        before :each do
          allow(monthly_sheet_item).to receive(:primary_code).and_return(current_program_code_number)
          allow(monthly_sheet_item).to receive(:name_text).and_return(current_program_name_text)
        end

        context 'and previous program matches neither code nor name' do
          before :example do
            previous_program
            .add_code(code_number: '01 02')
            .add_name(
              start_date: Date.new(2012, 1, 1),
              text: "#{current_program_name_text}aaa"
            )
          end

          it 'creates new program' do
            MonthlyBudgetSheet::ItemSaver.new(
              monthly_sheet_item,
              start_date: Date.new(2012, 4, 1)
            ).save_data_from_monthly_sheet_item

            new_program = Program.find_by_code(current_program_code_number)

            expect(new_program).to_not eq(nil)
            expect(new_program.name).to eq("#{current_program_name_text}")
            expect(new_program.possible_duplicates).to eq([])

            expect(new_program.spent_finances.last.amount).to eq(
              monthly_sheet_item_spent_finance_cumulative
            )

            expect(new_program.planned_finances.last.amount).to eq(
              monthly_sheet_item_planned_finance_cumulative
            )
          end
        end

        context 'and previous program matches code but not name' do
          before :example do
            previous_program
            .add_code(code_number: current_program_code_number)
            .add_name(
              start_date: Date.new(2012, 1, 1),
              text: "#{current_program_name_text}aaa"
            )
          end

          it 'creates separate program and marks them as possible duplicates' do
            MonthlyBudgetSheet::ItemSaver.new(
              monthly_sheet_item,
              start_date: Date.new(2012, 4, 1)
            ).save_data_from_monthly_sheet_item

            expect(previous_program.possible_duplicates[0].name)
            .to eq(current_program_name_text)
          end
        end

        context 'and previous program matches name but not code' do
          before :example do
            previous_program
            .add_code(code_number: '01 02')
            .add_name(
              start_date: Date.new(2012, 1, 1),
              text: "#{current_program_name_text}aaa"
            )
          end

          it 'adds data to previous program'
        end

        context 'and previous program matches code and name' do
          before :example do
            previous_program
            .add_code(code_number: current_program_code_number)
            .add_name(
              start_date: Date.new(2012, 1, 1),
              text: current_program_name_text
            )
          end

          it 'saves spent finance data to previous program' do
            MonthlyBudgetSheet::ItemSaver.new(
              monthly_sheet_item,
              start_date: Date.new(2012, 4, 1)
            ).save_data_from_monthly_sheet_item

            expect(previous_program.spent_finances.last.amount).to eq(
              monthly_sheet_item_spent_finance_cumulative - previous_spent_finance_amount
            )
          end

          it 'saves planned finance data to previous program' do
            MonthlyBudgetSheet::ItemSaver.new(
              monthly_sheet_item,
              start_date: Date.new(2012, 4, 1)
            ).save_data_from_monthly_sheet_item

            expect(previous_program.planned_finances.last.amount).to eq(
              monthly_sheet_item_planned_finance_cumulative - previous_planned_finance_amount
            )
          end
        end
      end
    end
  end
end
