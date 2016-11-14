require 'rails_helper'

RSpec.describe ItemOverlapGuard do
  let(:jan_2015) { Month.for_date(Date.new(2015, 1, 1)) }
  let(:feb_2015) { Month.for_date(Date.new(2015, 2, 1)) }
  let(:year_2015) { Year.for_date(Date.new(2015, 2, 1)) }

  describe '#overlap?' do
    context 'when items have overlapping monthly data' do
      it 'returns true' do
        item1 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: jan_2015.start_date,
            end_date: jan_2015.end_date))

        item2 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: jan_2015.start_date,
            end_date: jan_2015.end_date))

        expect(ItemOverlapGuard.new(item1, item2).overlap?).to eq(true)
      end
    end

    context 'when items have overlapping yearly data' do
      it 'returns true' do
        item1 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: year_2015.start_date,
            end_date: year_2015.end_date))

        item2 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: year_2015.start_date,
            end_date: year_2015.end_date))

        expect(ItemOverlapGuard.new(item1, item2).overlap?).to eq(true)
      end
    end

    context 'when items have non-overlapping monthly data' do
      it 'returns false' do
        item1 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: year_2015.start_date,
            end_date: year_2015.end_date))

        item2 = FactoryGirl.create(:program).add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance,
            start_date: feb_2015.start_date,
            end_date: feb_2015.end_date))

        expect(ItemOverlapGuard.new(item1, item2).overlap?).to eq(false)
      end
    end
  end
end
