require 'rails_helper'

describe MonthlyBudgetSheet::Item do
  let(:quarter1_2015) { Quarter.for_date(Date.new(2015, 1, 1)) }
  let(:quarter2_2015) { Quarter.for_date(Date.new(2015, 4, 1)) }

  let(:january_2015) { Month.for_date(Date.new(2015, 1, 1)) }
  let(:february_2015) { Month.for_date(Date.new(2015, 2, 1)) }

  describe '#save' do
    context 'when code matches previously saved item' do
      let(:code) { '01 83' }

      let(:previously_saved_item) do
        item = FactoryGirl.create(
          :program,
          code: code
        )

        FactoryGirl.create(
          :name,
          text: 'Program name1',
          nameable: item
        )

        item
      end

      let(:header_row) do
        header_row = instance_double(MonthlyBudgetSheet::Row, 'header_row')
        allow(header_row).to receive(:is_header?).and_return(true)
        allow(header_row).to receive(:is_totals_row?).and_return(false)
        allow(header_row).to receive(:code).and_return('01 83')

        header_row
      end

      let(:totals_row) do
        totals_row = instance_double(MonthlyBudgetSheet::Row, 'totals_row')
        allow(totals_row).to receive(:is_totals_row?).and_return(true)
        allow(totals_row).to receive(:spent_finance).and_return(300)
        allow(totals_row).to receive(:planned_finance).and_return(300)

        totals_row
      end

      let(:rows) do
        [
          header_row,
          totals_row
        ]
      end

      context "and name matches previously saved item's most recent name" do
        before :example do
          allow(header_row).to receive(:name).and_return('Program name1')
        end

        it 'saves planned_finance to previously saved item' do
          previously_saved_item.add_planned_finance(
            time_period: quarter1_2015,
            announce_date: Date.new(2015, 1, 1),
            amount: 100
          )

          new_budget_item = MonthlyBudgetSheet::Item.new(
            rows,
            start_date: quarter2_2015.start_date
          )

          new_budget_item.save

          previously_saved_item.reload
          expect(previously_saved_item.planned_finances.last.amount).to eq(300 - 100)
        end

        it 'saves spent_finance to previously saved item' do
          FactoryGirl.create(
            :spent_finance,
            time_period: january_2015,
            amount: 100,
            finance_spendable: previously_saved_item
          )

          new_budget_item = MonthlyBudgetSheet::Item.new(
            rows,
            start_date: february_2015.start_date
          )

          new_budget_item.save

          previously_saved_item.reload
          expect(previously_saved_item.spent_finances.last.amount).to eq(300 - 100)
        end
      end

      context "but name does not match previously saved item's most recent name" do
        it 'creates a new budget item' do
          allow(header_row).to receive(:name).and_return('Program name2')

          FactoryGirl.create(
            :spent_finance,
            time_period: january_2015,
            amount: 100,
            finance_spendable: previously_saved_item
          )

          new_budget_item = MonthlyBudgetSheet::Item.new(
            rows,
            start_date: february_2015.start_date
          )

          new_budget_item.save

          previously_saved_item.reload

          expect(new_budget_item.budget_item_object)
          .to_not eq(previously_saved_item)
        end
      end
    end

    context 'when code does not match previously saved item' do
      context "and name matches previously saved item's most recent name" do
        it 'creates a new budget item'
      end

      context "and name does not match previously saved item's most recent name" do
        it 'creates a new budget item'
      end
    end
  end
end
