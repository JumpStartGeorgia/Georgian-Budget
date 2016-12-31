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
  end
end
