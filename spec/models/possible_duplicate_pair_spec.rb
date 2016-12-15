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

  describe '#date_when_found' do
    it 'is required' do
      possible_duplicate_pair.date_when_found = nil

      expect(possible_duplicate_pair.valid?).to eq(false)
      expect(possible_duplicate_pair).to have(1).error_on(:date_when_found)
    end
  end

  describe '#found_on_first_day_of_year' do
    context 'when day is Jan 1 2015' do
      it 'returns true' do
        pair = create(:possible_duplicate_pair,
          date_when_found: Date.new(2015, 1, 1))

        expect(pair.found_on_first_day_of_year).to eq(true)
      end
    end

    context 'when day is Feb 1 2015' do
      it 'returns false' do
        pair = create(:possible_duplicate_pair,
          date_when_found: Date.new(2015, 2, 1))

        expect(pair.found_on_first_day_of_year).to eq(false)
      end
    end
  end

  context '#create' do
    context 'with items array' do
      let(:earlier_item) do
        FactoryGirl.create(
          :program,
          start_date: Date.new(2012, 1, 1)
        )
      end

      let(:later_item) do
        FactoryGirl.create(
          :program,
          start_date: Date.new(2012, 1, 2)
        )
      end

      it 'saves item1 as item with earlier start date' do
        pair = PossibleDuplicatePair.create(items: [
          later_item,
          earlier_item
        ])

        expect(pair.item1).to eq(earlier_item)
      end

      it 'saves item2 as item with later start date' do
        pair = PossibleDuplicatePair.create(items: [
          later_item,
          earlier_item
        ])

        expect(pair.item2).to eq(later_item)
      end
    end
  end
end
