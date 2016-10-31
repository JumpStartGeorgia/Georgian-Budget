require 'rails_helper'

Rspec.describe PossibleDuplicatePair, type: :model do
  let(:possible_duplicate_pair) do
    FactoryGirl.create(:possible_duplicate_pair)
  end

  context 'with valid attributes' do
    it 'is valid' do
      expect(possible_duplicate_pair.valid?).to eq(true)
    end
  end

  describe '#item1' do
    it 'is required' do
      possible_duplicate_pair.item1 = nil

      expect(possible_duplicate_pair.valid?).to eq(false)
      expect(possible_duplicate_pair).to have(1).error_on(:item1_id)
    end
  end

  describe '#item2' do
    it 'is required' do
      possible_duplicate_pair.item2 = nil

      expect(possible_duplicate_pair.valid?).to eq(false)
      expect(possible_duplicate_pair).to have(1).error_on(:item2_id)
    end

    it 'is unique for same type and item1_id' do
      pair2 = FactoryGirl.build(
        :possible_duplicate_pair,
        item1: possible_duplicate_pair.item1,
        item2: possible_duplicate_pair.item2)

      expect(pair2.valid?).to eq(false)
      expect(pair2).to have(1).error_on(:item2_id)
    end

    it 'cannot be the same as item1' do
      possible_duplicate_pair.item2 = possible_duplicate_pair.item1

      expect(possible_duplicate_pair.valid?).to eq(false)
      expect(possible_duplicate_pair).to have(1).error_on(:item2_id)
    end

    it 'must have same type as item1' do
      possible_duplicate_pair.item2 = FactoryGirl.create(:spending_agency)

      expect(possible_duplicate_pair.valid?).to eq(false)
      expect(possible_duplicate_pair).to have(1).error_on(:item2_id)
    end

    context 'when other pair already exists with same items but reversed' do
      it 'has error' do
        pair2 = FactoryGirl.build(
          :possible_duplicate_pair,
          item1: possible_duplicate_pair.item2,
          item2: possible_duplicate_pair.item1)

        expect(pair2.valid?).to eq(false)
        expect(pair2).to have(1).error_on(:item2_id)
      end
    end
  end
end
