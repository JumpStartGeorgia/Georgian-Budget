require 'rails_helper'

RSpec.shared_examples_for 'BudgetItemDuplicatable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:earlier_saved_code_attr) { FactoryGirl.attributes_for(:code) }
  let(:later_saved_code_attr) { FactoryGirl.attributes_for(:code) }
  let(:new_code_attr) { FactoryGirl.attributes_for(:code) }

  let(:earlier_saved_name_attr) { FactoryGirl.attributes_for(:name) }
  let(:later_saved_name_attr) { FactoryGirl.attributes_for(:name) }
  let(:new_name_attr) { FactoryGirl.attributes_for(:name) }

  let(:previously_saved_budget_item1) do
    FactoryGirl.create(described_class_sym)
  end

  let(:previously_saved_budget_item2) do
    FactoryGirl.create(described_class_sym)
  end

  let(:new_budget_item) do
    FactoryGirl.create(described_class_sym)
  end

  describe '#possible_duplicates' do
    context 'when budget_item is item1 in one duplicate pair and item2 in another' do
      it 'returns array with both duplicate budget_items' do
        FactoryGirl.create(:possible_duplicate_pair,
          item1: new_budget_item,
          item2: previously_saved_budget_item1)

        FactoryGirl.create(:possible_duplicate_pair,
          item1: previously_saved_budget_item2,
          item2: new_budget_item)

        expect(new_budget_item.possible_duplicates)
        .to match_array([previously_saved_budget_item1, previously_saved_budget_item2])
      end
    end
  end
end
