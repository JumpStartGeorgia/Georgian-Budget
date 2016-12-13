require 'rails_helper'

RSpec.describe PriorityFinancer::Spent do
  let(:priority) { FactoryGirl.create(:priority) }
  let(:spent_finances) { SpentFinance.all }

  let(:do_update_spent_finances!) do
    PriorityFinancer::Spent.new(priority)
    .update_from(spent_finances)
  end

  describe '#update_from' do
    context 'when spent finances fall belong to three time periods' do
      before do
        create_list(:spent_finance, 3, time_period_obj: Year.new(2012))
        create_list(:spent_finance, 2,
          time_period_obj: Quarter.for_date(Date.new(2012, 1, 1)))
        create(:spent_finance, time_period_obj:
          Month.for_date(Date.new(2015, 1, 1)))
      end

      it 'saves three spent finances to priority' do
        do_update_spent_finances!
        expect(priority.all_spent_finances.length).to eq(3)
      end
    end

    context 'when time period has one nil and two non-nil amount finances' do
      before do
        spent = create_list(:spent_finance, 3, time_period_obj: Year.new(2013))

        spent[2].update_attributes(amount: nil)
      end

      it 'saves spent finance to priority with the sum of the non-nil amounts' do
        do_update_spent_finances!

        expect(priority.all_spent_finances.length).to eq(1)
        expect(priority.all_spent_finances[0].amount)
        .to eq(spent_finances[0].amount + spent_finances[1].amount)

        expect(priority.all_spent_finances[0].time_period_obj)
        .to eq(spent_finances[0].time_period_obj)

        expect(priority.all_spent_finances[0].official)
        .to eq(false)
      end
    end

    context 'when time period has two nil amount finances' do
      before do
        create_list(:spent_finance,
          2,
          amount: nil,
          time_period_obj: Year.new(2013))
      end

      it 'saves spent finance with nil amount' do
        do_update_spent_finances!

        expect(priority.all_spent_finances.length).to eq(1)
        expect(priority.all_spent_finances[0].amount).to eq(nil)
        expect(priority.all_spent_finances[0].official).to eq(false)
      end
    end
  end
end
