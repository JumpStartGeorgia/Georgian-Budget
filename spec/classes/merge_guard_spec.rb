require 'rails_helper'

RSpec.describe MergeGuard do
  subject(:enforce_merge_okay!) { MergeGuard.new(item1, item2).enforce_merge_okay }

  describe '#enforce_merge_okay' do
    context 'when everything is okay' do
      let(:item1) { create(:spending_agency) }
      let(:item2) { create(:spending_agency) }

      before do
        create(:spent_finance,
          finance_spendable: item1,
          time_period_obj: Month.for_date(Date.new(2012, 1, 1)))

        create(:spent_finance,
          finance_spendable: item2,
          time_period_obj: Month.for_date(Date.new(2012, 2, 1)))

        create(:planned_finance,
          finance_plannable: item1,
          time_period_obj: Month.for_date(Date.new(2012, 3, 1)))

        create(:planned_finance,
          finance_plannable: item2,
          time_period_obj: Month.for_date(Date.new(2012, 4, 1)))
      end

      it 'does not raise error' do
        expect { enforce_merge_okay! }.not_to raise_error
      end
    end

    context 'when items are the same' do
      let(:item1) { create(:spending_agency) }
      let(:item2) { item1 }

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end

    context 'when items are different types' do
      let(:item1) { create(:spending_agency) }
      let(:item2) { create(:program) }

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end

    context 'when item1 monthly spent finances are after those of item2' do
      let(:item1) { create(:program) }
      let(:item2) { create(:program) }

      before do
        create(:spent_finance,
          finance_spendable: item1,
          time_period_obj: Month.for_date(Date.new(2012, 2, 1)))

        create(:spent_finance,
          finance_spendable: item2,
          time_period_obj: Month.for_date(Date.new(2012, 1, 1)))
      end

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end

    context 'when item1 quarterly planned finances are after those of item2' do
      let(:item1) { create(:program) }
      let(:item2) { create(:program) }

      before do
        create(:planned_finance,
          finance_plannable: item1,
          time_period_obj: Quarter.for_date(Date.new(2012, 4, 1)))

        create(:planned_finance,
          finance_plannable: item2,
          time_period_obj: Quarter.for_date(Date.new(2012, 1, 1)))
      end

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end
  end
end
