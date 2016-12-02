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

    context "when program's spent finances are requested" do
      let(:fields) { 'spent_finances' }
      let(:budget_item) do
        FactoryGirl.create(:program)
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: nil))
      end

      let(:hash_spent_finances) { hash['spent_finances'] }
      let(:hash_spent1) { hash_spent_finances[0] }
      let(:saved_spent1) { budget_item.spent_finances[0] }

      it 'includes all spent finances' do
        expect(hash_spent_finances.length).to eq(2)
      end

      it 'includes id of spent finance' do
        expect(hash_spent1[:id]).to eq(saved_spent1.id)
      end

      it 'includes time period of spent finance' do
        expect(hash_spent1[:time_period])
        .to eq(saved_spent1.time_period)
      end

      it 'includes time period type of spent finance' do
        expect(hash_spent1[:time_period_type])
        .to eq(saved_spent1.time_period_type)
      end

      it 'includes amount of spent finance' do
        expect(hash_spent1[:amount]).to eq(saved_spent1.amount)
      end
    end

    context "when program's planned finances are requested" do
      include_context 'months'

      let(:fields) { 'planned_finances' }
      let(:budget_item) do
        FactoryGirl.create(:program)
        .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
          time_period_obj: jan_2015))
        .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
          time_period_obj: feb_2015))
      end

      let(:hash_planned_finances) { hash['planned_finances'] }
      let(:hash_plan1) { hash_planned_finances[0] }
      let(:saved_plan1) { budget_item.planned_finances[0] }

      it 'includes all planned finances' do
        expect(hash_planned_finances.length).to eq(2)
      end

      it 'includes id of planned finance' do
        expect(hash_plan1[:id]).to eq(saved_plan1.id)
      end

      it 'includes time period of planned finance' do
        expect(hash_plan1[:time_period])
        .to eq(saved_plan1.time_period)
      end

      it 'includes time period type of planned finance' do
        expect(hash_plan1[:time_period_type])
        .to eq(saved_plan1.time_period_type)
      end

      it 'includes amount of planned finance' do
        expect(hash_plan1[:amount]).to eq(saved_plan1.amount)
      end
    end
  end
end
