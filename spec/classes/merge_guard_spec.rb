require 'rails_helper'

RSpec.describe MergeGuard do
  subject(:enforce_merge_okay!) { MergeGuard.new(item1, item2).enforce_merge_okay }

  describe '#enforce_merge_okay' do
    context 'when everything is okay' do
      let(:item1) { create(:spending_agency) }
      let(:item2) { create(:spending_agency) }

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

    context 'when items have official spent finances in same month' do
      let(:item1) { create(:program) }
      let(:item2) { create(:program) }

      before do
        create(:spent_finance,
          finance_spendable: item1,
          official: true,
          time_period_obj: Month.for_date(Date.new(2011, 1, 1)))

        create(:spent_finance,
          finance_spendable: item2,
          official: true,
          time_period_obj: Month.for_date(Date.new(2011, 1, 1)))
      end

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end

    context 'when items have official spent finances in same year' do
      let(:item1) { create(:program) }
      let(:item2) { create(:program) }

      before do
        create(:spent_finance,
          finance_spendable: item1,
          official: true,
          time_period_obj: Year.new(2011))

        create(:spent_finance,
          finance_spendable: item2,
          official: true,
          time_period_obj: Year.new(2011))
      end

      it 'raises error' do
        expect { enforce_merge_okay! }.to raise_error(MergeImpossibleError)
      end
    end
  end
end
