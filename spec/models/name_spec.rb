require 'rails_helper'

RSpec.describe Name, type: :model do
  let(:name1) do
    FactoryGirl.create(
      :name,
      nameable: FactoryGirl.create(:program)
    )
  end

  let(:name1b) do
    FactoryGirl.create(
      :name,
      start_date: name1.start_date + 1,
      nameable: name1.nameable
    )
  end

  describe '#nameable' do
    it 'is required' do
      name1.nameable = nil

      expect(name1).to have(1).error_on(:nameable)
    end
  end

  describe '#is_most_recent' do
    context 'when new name has no siblings' do
      it 'is true' do
        expect(name1.reload.is_most_recent).to eq(true)
      end
    end

    context 'when new name has a sibling' do
      before :example do
        name1b.save!
        name1b.nameable.reload
      end

      context 'when its start date is most recent' do
        before :each do
          name1.start_date = name1b.start_date + 1
          name1.save!
        end

        it 'is true' do
          name1.reload
          expect(name1.is_most_recent).to eq(true)
        end

        it 'is false for the other name' do
          name1b.reload
          expect(name1b.is_most_recent).to eq(false)
        end
      end

      context 'when its start date is not most recent' do
        before :each do
          name1.start_date = name1b.start_date - 1
          name1.save!
        end

        it 'is false' do
          name1.reload
          expect(name1.is_most_recent).to eq(false)
        end

        it 'is true for the sibling' do
          name1b.reload
          expect(name1b.is_most_recent).to eq(true)
        end
      end

    end
  end

  describe '#start_date' do
    it 'is required' do
      name1.start_date = nil
      name1.valid?

      expect(name1).to have(1).errors_on(:start_date)
    end

    context 'when name has siblings' do
      it "cannot be the same as another sibling's start date" do
        name1b.start_date = name1.start_date
        name1b.valid?

        expect(name1b).to have(1).errors_on(:start_date)
      end
    end
  end
end
