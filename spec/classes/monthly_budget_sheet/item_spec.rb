require 'rails_helper'

describe MonthlyBudgetSheet::Item do
  let(:quarter2) { Quarter.for_date(Date.new(2015, 4, 1)) }

  describe '#save' do
    context 'when code matches previously saved item' do
      context "and name matches previously saved item's most recent name" do
        it 'saves planned_finance to previously saved item' do
          code = '01 83'
          name = 'Program name!'

          previously_saved_item = FactoryGirl.create(
            :program,
            code: code
          )

          Name.create(text: name, nameable: previously_saved_item)

          previously_saved_item.add_planned_finance(
            time_period: Quarter.for_date(Date.new(2015, 1, 1)),
            announce_date: Date.new(2015, 1, 1),
            amount: 100
          )

          header_row = instance_double(MonthlyBudgetSheet::Row, 'header_row')
          allow(header_row).to receive(:is_header?).and_return(true)
          allow(header_row).to receive(:is_totals_row?).and_return(false)
          allow(header_row).to receive(:code).and_return('01 83')
          allow(header_row).to receive(:name).and_return('Program name!')

          totals_row = instance_double(MonthlyBudgetSheet::Row, 'totals_row')
          allow(totals_row).to receive(:is_totals_row?).and_return(true)
          allow(totals_row).to receive(:spent_finance).and_return(100)
          allow(totals_row).to receive(:planned_finance).and_return(300)

          rows = [
            header_row,
            totals_row
          ]

          new_budget_item = MonthlyBudgetSheet::Item.new(
            rows,
            quarter2.start_date,
            quarter2.end_date
          )

          new_budget_item.save

          previously_saved_item.reload
          expect(previously_saved_item.planned_finances.last.amount).to eq(300 - 100)
        end

        it 'saves spent_finance to previously saved item'
      end

      context "but name does not match previously saved item's most recent name" do
        it 'creates a new budget item'
      end
    end

    context 'when code does not match previously saved item' do
      it 'creates a new budget item'
    end
  end
end
