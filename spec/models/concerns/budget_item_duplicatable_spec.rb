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

  describe '#save_possible_duplicates' do
    context 'when no other budget_items have same code or name' do
      it 'does not save any possible duplicates' do
        previously_saved_budget_item1
        previously_saved_budget_item2

        new_budget_item.add_code(new_code_attr)
        new_budget_item.add_name(new_name_attr)

        new_budget_item.save_possible_duplicates

        expect(new_budget_item.possible_duplicates).to eq([])
      end
    end

    context 'when two other budget_items have same code' do
      it 'returns the more recent budget_item in an array' do
        earlier_saved_code_attr[:number] = new_code_attr[:number]
        previously_saved_budget_item1.add_code(earlier_saved_code_attr)

        later_saved_code_attr[:number] = new_code_attr[:number]
        previously_saved_budget_item2.add_code(later_saved_code_attr)

        previously_saved_budget_item1.update_column(
          :start_date,
          previously_saved_budget_item2.start_date + 1)

        new_budget_item.add_code(new_code_attr)

        new_budget_item.save_possible_duplicates

        expect(new_budget_item.possible_duplicates).to eq([previously_saved_budget_item1])
      end
    end

    context 'when two other budget_items have same name' do
      it 'returns the budget_item with more recent start date in an array' do
        earlier_saved_name_attr[:text] = new_name_attr[:text]
        previously_saved_budget_item1.add_name(earlier_saved_name_attr)

        later_saved_name_attr[:text] = new_name_attr[:text]
        previously_saved_budget_item2.add_name(later_saved_name_attr)

        previously_saved_budget_item1.update_column(
          :start_date,
          previously_saved_budget_item2.start_date + 1)

        new_budget_item.add_name(new_name_attr)

        new_budget_item.save_possible_duplicates

        expect(new_budget_item.possible_duplicates).to eq([previously_saved_budget_item1])
      end
    end
  end

  describe '#possible_duplicates' do
    context 'when budget_item is item1 in one duplicate pair and item2 in another' do
      it 'returns array with both duplicate budget_items' do
        PossibleDuplicatePair.create(items: [
          new_budget_item,
          previously_saved_budget_item1
        ])

        PossibleDuplicatePair.create(items: [
          previously_saved_budget_item2,
          new_budget_item
        ])

        expect(new_budget_item.possible_duplicates)
        .to match_array([previously_saved_budget_item1, previously_saved_budget_item2])
      end
    end
  end
end
