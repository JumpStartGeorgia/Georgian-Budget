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
  end
end
