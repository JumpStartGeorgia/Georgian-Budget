require 'rails_helper'

RSpec.shared_examples_for 'BudgetItemDuplicatable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:previously_saved_budget_item1) do
    FactoryGirl.create(
      described_class_sym,
      code: '')
  end

  let(:previously_saved_budget_item2) do
    FactoryGirl.create(
      described_class_sym,
      code: '')
  end

  let(:budget_item) do
    FactoryGirl.create(
      described_class_sym,
      code: '01 01')
  end

  describe '#save_possible_duplicates' do
    context 'when no other budget_items have same code or name' do
      it 'returns empty array' do
        previously_saved_budget_item1
        previously_saved_budget_item2

        budget_item.save_possible_duplicates

        expect(
          previously_saved_budget_item1.possible_duplicates.include?(budget_item) ||
          previously_saved_budget_item2.possible_duplicates.include?(budget_item)
        ).to eq(false)
      end
    end

    context 'when two other budget_items have same code' do
      it 'returns the more recent budget_item in an array' do
        previously_saved_budget_item1.code = budget_item.code
        previously_saved_budget_item1.save!

        previously_saved_budget_item2.code = budget_item.code
        previously_saved_budget_item2.save!

        budget_item.save_possible_duplicates

        expect(
          previously_saved_budget_item1.possible_duplicates.include?(budget_item) ||
          previously_saved_budget_item2.possible_duplicates.include?(budget_item)
        ).to eq(true)
      end
    end

    context 'when two other budget_items have same name' do
      it 'returns the more recently named budget_item in an array' do
        name_text = 'fjiepwjfipejw'
        Name.create(
          nameable: previously_saved_budget_item1,
          start_date: Date.new(2012, 2, 1),
          text: name_text)

        Name.create(
          nameable: previously_saved_budget_item2,
          start_date: Date.new(2012, 3, 1),
          text: name_text)

        previously_saved_budget_item2.reload.save_possible_duplicates

        Name.create(
          nameable: budget_item,
          start_date: Date.new(2013, 1, 1),
          text: name_text)

        budget_item.save_possible_duplicates

        expect(
          previously_saved_budget_item1.possible_duplicates.include?(budget_item) ||
          previously_saved_budget_item2.possible_duplicates.include?(budget_item)
        ).to eq(true)
      end
    end
  end

  describe '#possible_duplicates' do
    context 'when budget_item is item1 in one duplicate pair and item2 in another' do
      it 'returns array with both duplicate budget_items' do
        PossibleDuplicatePair.create(
          item1: budget_item,
          item2: previously_saved_budget_item1)

        PossibleDuplicatePair.create(
          item1: previously_saved_budget_item2,
          item2: budget_item)

        expect(budget_item.possible_duplicates)
        .to match_array([previously_saved_budget_item1, previously_saved_budget_item2])
      end
    end
  end
end
