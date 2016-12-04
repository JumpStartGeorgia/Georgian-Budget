require 'rails_helper'

RSpec.describe FinanceCategorizer do
  describe '#set_primary' do
    context 'when spent finance has no matching siblings' do
      it 'sets primary to true' do
        spent = FactoryGirl.create(:spent_finance, primary: false)

        FinanceCategorizer.new(spent).set_primary

        expect(spent.primary).to eq(true)
      end
    end

    context 'when spent finance is official and has matching unofficial sibling' do
      let!(:unofficial_spent) do
        FactoryGirl.create(:spent_finance, official: false, primary: true)
      end

      let!(:official_spent) do
        FactoryGirl.create(:spent_finance,
          official: true,
          primary: false,
          time_period_obj: unofficial_spent.time_period_obj,
          finance_spendable: unofficial_spent.finance_spendable
        )
      end

      before do
        FinanceCategorizer.new(official_spent).set_primary
      end

      it 'marks official finance as primary' do
        expect(official_spent.reload.primary).to eq(true)
      end

      it 'marks unofficial finance as not primary' do
        expect(unofficial_spent.reload.primary).to eq(false)
      end
    end
  end
end
