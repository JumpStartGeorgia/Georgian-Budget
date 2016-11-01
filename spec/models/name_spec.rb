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

  describe '#text=' do
    it 'cleans text of extra spaces' do
      name = FactoryGirl.create(:name, text: 'my  name')
      expect(name.text).to eq('my name')
    end

    it 'strips text of surrounding space' do
      name = FactoryGirl.create(:name, text: ' my name ')
      expect(name.text).to eq('my name')
    end
  end

  describe '.texts_functionally_equivalent?' do
    it 'returns false if text is different' do
      text1 = 'Name1'
      text2 = 'Name2'
      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(false)
    end

    it 'returns true if difference is short dash vs. space' do
      text1 = 'Name-1'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is long dash vs. space' do
      text1 = 'Name—1'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is comma vs. space' do
      text1 = 'Name, 1'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is parentheses vs. space' do
      text1 = 'Name (1)'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is forward slash vs. space' do
      text1 = 'Name/1'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is backward slash vs. space' do
      text1 = 'Name\1'
      text2 = 'Name 1'

      expect(Name.texts_functionally_equivalent?(text1, text2)).to eq(true)
    end
  end
end
