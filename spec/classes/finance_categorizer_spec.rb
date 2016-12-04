require 'rails_helper'

RSpec.describe FinanceCategorizer do
  describe '#set_primary' do
    context 'when finance is unofficial and has sibling with different time period' do
      let!(:non_matching_sibling) do
        FactoryGirl.create(:spent_finance,
          official: false,
          primary: true)
      end

      let!(:finance) do
        FactoryGirl.create(:spent_finance,
          primary: false,
          official: false,
          budget_item: non_matching_sibling.budget_item)
      end

      before do
        FinanceCategorizer.new(finance).set_primary
      end

      it 'marks finance as primary' do
        expect(finance.primary).to eq(true)
      end

      it 'does not change non matching sibling primary value' do
        expect(non_matching_sibling.primary).to eq(true)
      end
    end

    context 'when finance is official and has unofficial version' do
      let!(:finance) do
        FactoryGirl.create(:spent_finance, official: true, primary: false)
      end

      let!(:unofficial_version) do
        FactoryGirl.create(:spent_finance,
          official: false,
          primary: true,
          time_period_obj: finance.time_period_obj,
          budget_item: finance.budget_item
        )
      end

      before do
        FinanceCategorizer.new(finance).set_primary
      end

      it 'marks finance as primary' do
        expect(finance.reload.primary).to eq(true)
      end

      it 'marks unofficial version as not primary' do
        expect(unofficial_version.reload.primary).to eq(false)
      end
    end

    context 'when finance is official and has later announced unofficial version' do
      let!(:finance) do
        FactoryGirl.create(:planned_finance, official: true, primary: false)
      end

      let!(:more_recent_unofficial_version) do
        FactoryGirl.create(:planned_finance,
          official: false,
          primary: true,
          time_period_obj: finance.time_period_obj,
          announce_date: finance.announce_date + 1,
          budget_item: finance.budget_item)
      end

      before do
        FinanceCategorizer.new(finance).set_primary
      end

      it 'marks finance as primary' do
        expect(finance.reload.primary).to eq(true)
      end

      it 'marks more recent unofficial finance as not primary' do
        expect(more_recent_unofficial_version.reload.primary).to eq(false)
      end
    end

    context 'when finance is unofficial and has less recently announced unofficial version' do
      let!(:finance) do
        FactoryGirl.create(:planned_finance, official: false, primary: false)
      end

      let!(:less_recent_unofficial) do
        FactoryGirl.create(:planned_finance,
          official: false,
          primary: true,
          time_period_obj: finance.time_period_obj,
          announce_date: finance.announce_date - 1,
          budget_item: finance.budget_item)
      end

      before do
        FinanceCategorizer.new(finance).set_primary
      end

      it 'marks finance as primary' do
        expect(finance.reload.primary).to eq(true)
      end

      it 'marks other version as not primary' do
        expect(less_recent_unofficial.reload.primary).to eq(false)
      end
    end
  end
end
