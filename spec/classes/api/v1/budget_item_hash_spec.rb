require 'rails_helper'

RSpec.describe API::V1::BudgetItemHash do
  describe '#to_hash' do
    let(:hash) { API::V1::BudgetItemHash.new(budget_item, fields).to_hash }

    context 'when id, code and name are requested for priority' do
      let!(:budget_item) do
        FactoryGirl.create(:priority)
        .add_name(FactoryGirl.attributes_for(:name))
        .save_perma_id
      end

      let!(:fields) { 'id,code,name' }

      it 'includes perma_id in hash as id' do
        expect(hash['id']).to eq(budget_item.perma_id)
      end

      it 'includes name in hash' do
        expect(hash['name']).to eq(budget_item.name)
      end

      it 'does not include code in hash' do
        expect(hash['code']).to eq(nil)
      end
    end
  end
end
