require 'rails_helper'

RSpec.describe BudgetDataSaver do
  describe '#save_data' do
    let!(:total_data_holder) do
      data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)
      allow(data_holder).to receive(:code_number).and_return('00')
      allow(data_holder).to receive(:spent_finance_data).and_return(      {
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        amount: 101
      })

      data_holder
    end

    context 'when code is 00 and total does not yet exist' do
      it 'creates total with new spent finance' do
        BudgetDataSaver.new(total_data_holder).save_data

        expect(Total.first).to_not eq(nil)
        expect(Total.first.spent_finances[0].amount).to eq(101)
      end
    end

    context 'when code is 00 and total already exists' do
      let!(:total) { FactoryGirl.create(:total) }

      it 'adds spent finance data to the total' do
        BudgetDataSaver.new(total_data_holder).save_data

        expect(total.spent_finances[0].amount).to eq(101)
      end
    end

    context 'when data_holder contains program name and code' do
      it 'creates program with correct perma id' do
        data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)
        allow(data_holder).to receive(:code_number).and_return('01 0555')
        allow(data_holder).to receive(:publish_date).and_return(Date.new(2012, 1, 1))
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

    context 'when item is not a total' do
      it 'sets overall_budget to first total' do
        data_holder = instance_double(MonthlyBudgetSheet::ItemSaver)

      end
    end
  end
end
