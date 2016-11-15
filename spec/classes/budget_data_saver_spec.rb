require 'rails_helper'

RSpec.describe BudgetDataSaver do
  describe '#save_data' do
    context 'when code is 00' do
      context 'and total does not yet exist' do
        it 'creates total with new spent finance' do
          data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)
          allow(data_holder).to receive(:code_number).and_return('00')
          allow(data_holder).to receive(:spent_finance_data).and_return(      {
            time_period: Month.for_date(Date.new(2012, 1, 1)),
            amount: 101
          })

          BudgetDataSaver.new(data_holder).save_data

          expect(Total.first).to_not eq(nil)
          expect(Total.first.spent_finances[0].amount).to eq(101)
        end
      end

      context 'and total already exists' do
        let(:total) { FactoryGirl.create(:total) }

        it 'adds spent finance data to the total' do
          total

          data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)
          allow(data_holder).to receive(:code_number).and_return('00')
          allow(data_holder).to receive(:spent_finance_data).and_return(      {
            time_period: Month.for_date(Date.new(2012, 1, 1)),
            amount: 101
          })

          BudgetDataSaver.new(data_holder).save_data

          expect(Total.first.spent_finances[0].amount).to eq(101)
        end
      end
    end

    context 'when data_holder contains program name and code' do
      it 'creates program with correct perma id' do
        data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)
        allow(data_holder).to receive(:code_number).and_return('01 0555')
        allow(data_holder).to receive(:code_data).and_return({
          start_date: Date.new(2012, 1, 1),
          number: '01 0555'
        })
        allow(data_holder).to receive(:name_data).and_return({
          start_date: Date.new(2012, 1, 1),
          text_ka: 'my-name'
        })

        BudgetDataSaver.new(data_holder).save_data

        program = Program.find_by_code('01 0555')

        expect(program.perma_ids[0].text).to eq(
          Digest::SHA1.hexdigest '01_0555_my_name'
        )
      end
    end
  end
end
